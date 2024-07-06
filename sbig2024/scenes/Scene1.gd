extends Node

signal level_won
signal level_lost

@export var vidscreen_sound: AudioStream

@onready var character: FPCharacter = $Character
@onready var apartment: ApartmentHallScene = $ApartmentHallScene

enum StickerStates { NOT_DONE, DOING, DONE }

var sticker_state: StickerStates = StickerStates.NOT_DONE

enum Scene1State {
	SPAWNED,
	STICKER_GOT,
	IN_HALLWAY,
	HALL_1,
	HALL_2,
	HALL_3,
	DONE
}

@export var _state: Scene1State = Scene1State.SPAWNED

@export var _instruction_1: String = "Grab the sticker."
@export var _instruction_2: String = "Hold E to take the sticker."
@export var _instruction_3: String = "Time to go."

@export var _intro_text_1: String = "11BelowStudio presents"
@export var _intro_text_2: String = "This year's SBIGJam entry"
@export_multiline var _intro_text_2a:String = "3D Models: Delta100\nPercival: Himself\nThe other voice acting: Virety Rammithel"
@export var _intro_text_3: String = "Flypost"

@export var _sticker_duration: float = 3
@export var _sticker_progress: float = 0
@export var _sticker_decay_delta: float = 0.9


@export var intensity: float = 0
@export var _min_door_dist_intensity: float = 6
@export var _max_door_dist_intensity: float = 24

func _door_dist_intensity_range():
	return _max_door_dist_intensity - _min_door_dist_intensity

var _player_in_hall: bool = false
@onready var _heartbeater = $Heartbeater

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	character.holding_sticker = false
	apartment.fpui.progress.max_value = _sticker_duration
	apartment.fpui.show_instruction(_instruction_1)
	apartment.play_vidscreen_audio(vidscreen_sound)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if _player_in_hall:
		var dist_to_door: float = character.global_position.distance_to(apartment.exitDoor.global_position)
		if dist_to_door >= _max_door_dist_intensity:
			intensity = 0
		elif dist_to_door <= _min_door_dist_intensity:
			intensity = 1
		else:
			intensity = 1 - ((dist_to_door - _min_door_dist_intensity)/_door_dist_intensity_range())
		_heartbeater.intensity_target = intensity
		apartment.fpui.vignette_intensity(intensity)
	
	if _state == Scene1State.SPAWNED:
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

func _physics_process(delta: float) -> void:
	if _state == Scene1State.SPAWNED:
		match sticker_state:
			StickerStates.NOT_DONE:
				var characterUseObj: StickerBase = character.get_use_raycast_target() as StickerBase
				if characterUseObj and characterUseObj == apartment.sticker:
					apartment.fpui.show_instruction(_instruction_2)
					if Input.is_action_just_pressed(character.USE):
						sticker_state = StickerStates.DOING
						apartment.sticker.start_stickering()
				else:
					apartment.fpui.show_instruction(_instruction_1)
			StickerStates.DOING:
				if Input.is_action_pressed(character.USE):
					var characterUseObj: StickerBase = character.get_use_raycast_target() as StickerBase
					if (not characterUseObj) or (characterUseObj != apartment.sticker):
						sticker_state = StickerStates.NOT_DONE
						apartment.sticker.abort_stickering()
				else:
					sticker_state = StickerStates.NOT_DONE
					apartment.sticker.abort_stickering()
			_:
				pass
		pass

func _sticker_got() -> void:
	if _state == Scene1State.SPAWNED:
		_state = Scene1State.STICKER_GOT
		apartment.fpui.show_instruction(_instruction_3)
		apartment.sticker.use()
		apartment.apartmentDoor.open_door()
		character.holding_sticker = true
	pass

func _on_apartment_hall_scene_player_door_area() -> void:
	if _state == Scene1State.STICKER_GOT:
		apartment.fpui.hide_instruction()
		_state = Scene1State.IN_HALLWAY
	pass # Replace with function body.


func _on_apartment_hall_scene_player_hall_1() -> void:
	if _state == Scene1State.IN_HALLWAY:
		apartment.fpui.show_intro_a(_intro_text_1)
		_state = Scene1State.HALL_1
	pass # Replace with function body.


func _on_apartment_hall_scene_player_hall_2() -> void:
	if _state == Scene1State.HALL_1:
		apartment.fpui.show_intro_a(_intro_text_2)
		apartment.fpui.show_instruction(_intro_text_2a)
		_state = Scene1State.HALL_2
	pass # Replace with function body.


func _on_apartment_hall_scene_player_hall_3() -> void:
	if _state == Scene1State.HALL_2:
		apartment.fpui.hide_intro_a()
		apartment.fpui.show_intro_b(_intro_text_3)
		apartment.fpui.hide_instruction()
		_state = Scene1State.HALL_3
	pass # Replace with function body.

func _on_apartment_hall_scene_player_exit_area() -> void:
	if _state != Scene1State.DONE:
		_state = Scene1State.DONE
		level_won.emit()
	pass # Replace with function body.


func _on_apartment_hall_scene_player_entered_hall() -> void:
	_player_in_hall = true
	_heartbeater.vol_target = 1
	pass # Replace with function body.


func _on_apartment_hall_scene_player_left_hall() -> void:
	_player_in_hall = false
	_heartbeater.vol_target = 0
	pass # Replace with function body.
