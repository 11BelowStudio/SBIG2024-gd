extends Node3D


@export var vidscreen_sound: AudioStream

enum StickerStates { NOT_DONE, DOING, DONE }

var sticker_state: StickerStates = StickerStates.NOT_DONE

enum FSceneState {
	SPAWNED,
	STICKER_GOT,
	CHASE
}

var _state: FSceneState = FSceneState.SPAWNED

@export var _sticker_duration: float = 3
@export var _sticker_progress: float = 0
@export var _sticker_decay_delta: float = 0.9


@export var _instruction_1: String = "Grab the sticker."
@export var _instruction_2: String = "Hold E to take the sticker."
@export var _instruction_3: String = "Time to go."


@onready var character: FPCharacter = $Character
@onready var apartment: ApartmentHallScene = $ApartmentHallScene
@onready var heartbeater: Heartbeater = $Heartbeater
@onready var wNoiseControl: WhiteNoiseControl = $WhiteNoiseControl

@export var _enforcerScene: PackedScene
var _enforcer: Enforcer

var _enforcementInProgress: bool = false

var _enforcerReachedMiddle: bool = false

@export var intensity: float = 0
@export var _min_door_dist_intensity: float = 6
@export var _max_door_dist_intensity: float = 24

func _door_dist_intensity_range():
	return _max_door_dist_intensity - _min_door_dist_intensity

var _player_in_hall: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	character.holding_sticker = false
	apartment.fpui.progress.max_value = _sticker_duration
	apartment.fpui.show_instruction(_instruction_1)
	apartment.fpui.vignette_intensity(0)
	apartment.play_vidscreen_audio(vidscreen_sound)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if _state == FSceneState.SPAWNED:
		match sticker_state:
			StickerStates.NOT_DONE:

				_sticker_progress = lerpf(_sticker_progress, 0, _sticker_decay_delta * delta)
				apartment.fpui.progress.value = _sticker_progress
			StickerStates.DOING:
				_sticker_progress += delta
				apartment.fpui.progress.value = _sticker_progress
				if _sticker_progress >= _sticker_duration:
					_sticker_got()
			_:
				pass
		pass
	
	pass
	
	if _state == FSceneState.CHASE:
		_update_enforcer_dist_intensity()
		
		#print(_intensity)
		
		heartbeater.intensity_target = _enforcer_dist_intensity
		wNoiseControl.set_intensity01(_enforcer_dist_intensity)
		character.fov_intensity_target = _enforcer_dist_intensity
		apartment.fpui.vignette_intensity(_enforcer_dist_intensity)
	
	else:
		if _player_in_hall:
			var intensity = 0
			var dist_to_door: float = character.global_position.distance_to(apartment.exitDoor.global_position)
			if dist_to_door >= _max_door_dist_intensity:
				intensity = 0
			elif dist_to_door <= _min_door_dist_intensity:
				intensity = 1
			else:
				intensity = 1 - ((dist_to_door - _min_door_dist_intensity)/_door_dist_intensity_range())
			heartbeater.intensity_target = intensity
			apartment.fpui.vignette_intensity(intensity)


func _physics_process(delta: float) -> void:
	if _state == FSceneState.SPAWNED:
		match sticker_state:
			StickerStates.NOT_DONE:
				var characterUseObj: StickerBase = character.get_use_raycast_target() as StickerBase
				if characterUseObj and characterUseObj == apartment.sticker:
					apartment.fpui.show_instruction(_instruction_2)
					if Input.is_action_just_pressed(character.USE):
						sticker_state = StickerStates.DOING
						#theSticker.placing_started()
				else:
					apartment.fpui.show_instruction(_instruction_1)
			StickerStates.DOING:
				if Input.is_action_pressed(character.USE):
					var characterUseObj: StickerBase = character.get_use_raycast_target() as StickerBase
					if (not characterUseObj) or (characterUseObj != apartment.sticker):
						sticker_state = StickerStates.NOT_DONE
						#theSticker.placing_aborted()
				else:
					sticker_state = StickerStates.NOT_DONE
					#theSticker.placing_aborted()
			_:
				pass
		pass


func _sticker_got() -> void:
	if _state == FSceneState.SPAWNED:
		_state = FSceneState.STICKER_GOT
		apartment.fpui.show_instruction(_instruction_3)
		apartment.sticker.use()
		apartment.apartmentDoor.open_door()
		character.holding_sticker = true
	pass


func _on_apartment_hall_scene_player_hall_3() -> void:
	if _enforcementInProgress:
		return
	_enforcementInProgress = true
	_state = FSceneState.CHASE
	
	_enforcer = _enforcerScene.instantiate()
	
	
	_enforcer.look_at_from_position(
		apartment.enforcerSpawn.position,
		apartment.enforcerMidHall.position,
		Vector3.UP
	)
	
	_enforcer.navigation_finished.connect(Callable(_on_enforcer_navigation_finished))
	
	
	_enforcer.init_ai(Enforcer.AiType.GIGA_MONTY)
	_enforcer.set_target_gm(apartment.enforcerMidHall)
	#_enforcer.set_target_gm(character)
	
	
	add_child(_enforcer)
	
	
	#_enforcer._target = apartment.enforcerMidHall
	
	apartment.enforcerDoor.open_door()
	
	_update_enforcer_dist_intensity()
	wNoiseControl.set_intensity01(_enforcer_dist_intensity)
	heartbeater.intensity = _enforcer_dist_intensity
	
	pass # Replace with function body.


func _on_enforcer_navigation_finished() -> void:
	if _enforcerReachedMiddle:
		pass
	_enforcerReachedMiddle = true
	_enforcer.set_target_gm(character)
	#wNoiseControl.set_intensity01(1)
	#heartbeater.intensity = 1


func _on_character_hit_by_enforcer() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
	pass # Replace with function body.







const DEFAULT_NO_ENFORCER_DIST: float = -1

@export var min_enforcer_dist: float = 4:
	set(value):
		min_enforcer_dist = value
		_enforcer_dist_range = _get_enforcer_dist_range()
@export var max_enforcer_dist: float = 25:
	set(value):
		max_enforcer_dist = value
		_enforcer_dist_range = _get_enforcer_dist_range()
@onready var _enforcer_dist_range: float = _get_enforcer_dist_range()

func _get_enforcer_dist_range() -> float:
	return max_enforcer_dist - min_enforcer_dist

var _enforcer_dist_intensity: float = 0



func _calc_enforcer_dist_intensity(closestDist: float) -> float:
	if (closestDist == DEFAULT_NO_ENFORCER_DIST) or (closestDist >= max_enforcer_dist):
		_enforcer_dist_intensity = 0
	elif closestDist <= min_enforcer_dist:
		_enforcer_dist_intensity = 1
	else:
		_enforcer_dist_intensity = 1 - ((closestDist - min_enforcer_dist)/_enforcer_dist_range)
	return _enforcer_dist_intensity



func _update_enforcer_dist_intensity() -> void:
	var closest_dist: float = _get_closest_enforcer_dist()
	if closest_dist == DEFAULT_NO_ENFORCER_DIST or closest_dist >= max_enforcer_dist:
		_enforcer_dist_intensity = 0
		return
	elif closest_dist <= min_enforcer_dist:
		_enforcer_dist_intensity = 1
		return
	_enforcer_dist_intensity = 1 - ((closest_dist - min_enforcer_dist)/_enforcer_dist_range)
	pass

func _get_closest_enforcer_dist() -> float:
	if _enforcer:
		return character.global_position.distance_to(_enforcer.global_position)
	else:
		return DEFAULT_NO_ENFORCER_DIST



func _on_apartment_hall_scene_player_entered_hall() -> void:
	_player_in_hall = true
	heartbeater.vol_target = 1
	pass # Replace with function body.


func _on_apartment_hall_scene_player_left_hall() -> void:
	_player_in_hall = false
	if _state != FSceneState.CHASE:
		heartbeater.vol_target = 0
	pass # Replace with function body.


