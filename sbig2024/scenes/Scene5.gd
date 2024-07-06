extends Node

signal level_won
signal level_lost

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

@onready var heartbeater: Heartbeater = %Heartbeater
@onready var whitenoise: WhiteNoiseControl = %WhiteNoiseControl
@onready var dualAmbience: TwoTrackAmbience = %TwoTrackAmbience

@export var _enforcerScene: PackedScene
var _enforcer: Enforcer


@onready var theSticker: StickerBase = %StickerPlace

@onready var character: FPCharacter = $Character

@onready var ui: FPUI = $FPUI

@onready var drumLooper: DrumLooper = %DrumLooper


@export var _instruction_1: String = "Act natural, walk up to the statue, get it done."
@export var _instruction_2: String = "Get a bit closer, keep an eye out for enforcers (hold Q to look around)..."
@export var _instruction_3: String = "Hold E to stick."
@export var _instruction_4: String = "Keep calm, walk away, act natural..."


@export var USE : String = "use"

@export var _sticker_duration: float = 3
@export var _sticker_progress: float = 0
@export var _sticker_decay_delta: float = 0.9

enum SceneStates {
	SPAWNED,
	STICKER_PLACED,
	#FLEE,
	DONE
}
var _state: SceneStates = SceneStates.SPAWNED

enum StickerStates { NOT_DONE, DOING, DONE }

var sticker_state: StickerStates = StickerStates.NOT_DONE

## all of the enforcers (like every one of them)
@onready var enforcers: Array[Enforcer] = __get_enforcers():
	get:
		return __get_enforcers()


@export var _bump_interval: float = 0.5
var _bump_cooldown: float = 0


func __get_enforcers() -> Array[Enforcer]:
	if is_node_ready():
		var result: Array[Enforcer] = []
		for n in get_tree().get_nodes_in_group("enforcers"):#.filter(func(n): return n is Enforcer) as Array[Enforcer]
			if n is Enforcer:
				result.append(n as Enforcer)
		return result
	else:
		push_error("cannot get enforcers whilst this node isn't ready and such!")
		return []

var _intensity: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character.look_target = theSticker
	character.holding_sticker = true
	ui.progress.max_value = _sticker_duration
	
	
	
	for e in enforcers:
		e.ai_state_changed.connect(_on_enforcer_state_changed)
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if _bump_cooldown > 0:
		_bump_cooldown -= delta
	
	var char_intensity: float = character.get_dist_intensity()
	
	character.speed_intensity = char_intensity
	_update_enforcer_dist_intensity()
	_intensity = max(char_intensity, _enforcer_dist_intensity)
	
	
	#print(_intensity)
	
	heartbeater.intensity_target = _intensity
	dualAmbience.audio_weight_target = _intensity
	whitenoise.set_intensity01(_enforcer_dist_intensity)
	
	if _state != SceneStates.SPAWNED:
		ui.vignette_intensity(_intensity)
		character.fov_intensity_target = _intensity
	else:
		ui.vignette_intensity(char_intensity)
		character.fov_intensity_target = char_intensity
	
	match sticker_state:
		StickerStates.NOT_DONE:
			
			if char_intensity == 0:
				ui.show_instruction(_instruction_1)
			elif (char_intensity >= 0.35) and (char_intensity <= 0.8):
				ui.show_instruction(_instruction_2)
			
			_sticker_progress = lerpf(_sticker_progress, 0, _sticker_decay_delta * delta)
			ui.progressBar().value = _sticker_progress
		StickerStates.DOING:
			_sticker_progress += delta
			ui.progressBar().value = _sticker_progress
			if _sticker_progress >= _sticker_duration:
				_sticker_done()
		_:
			pass
	pass
	
	#print("progress: %1.3f state: %s" % [_sticker_placing_progress, sticker_state])
	
	pass

func _physics_process(delta: float) -> void:
	
	match sticker_state:
		StickerStates.NOT_DONE:
			var characterUseObj: StickerBase = character.get_use_raycast_target() as StickerBase
			if characterUseObj and characterUseObj == theSticker:
				ui.show_instruction(_instruction_3)
				if Input.is_action_just_pressed(USE):
					sticker_state = StickerStates.DOING
					theSticker.start_stickering()
			else:
				ui.show_instruction(_instruction_2)
		StickerStates.DOING:
			if Input.is_action_pressed(USE):
				var characterUseObj: StickerBase = character.get_use_raycast_target() as StickerBase
				if (not characterUseObj) or (characterUseObj != theSticker):
					sticker_state = StickerStates.NOT_DONE
					theSticker.abort_stickering()
			else:
				sticker_state = StickerStates.NOT_DONE
				theSticker.abort_stickering()
		_:
			pass
	
	
	pass


func _sticker_done() -> void:
	theSticker.use()
	character.holding_sticker = false
	sticker_state = StickerStates.DONE
	_state = SceneStates.STICKER_PLACED
	#heartbeater.intensity_target = _tar
	#dualAmbience.audio_weight_target = 0
	character.look_target = null
	ui.show_instruction(_instruction_4, 10)
	for e in enforcers:
		e.set_ai_override(Enforcer.AiOverride.AGGRESSIVE)
	_on_enforcer_state_changed()
	%IntroBlockers.free()




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
	if enforcers.is_empty():
		return DEFAULT_NO_ENFORCER_DIST
	elif enforcers.size() == 1:
		return character.global_position.distance_to(enforcers[0].global_position)
	
	var char_global: Vector3 = character.global_position
	var lowestSquareDist : float = INF
	for e in enforcers:
		var eSquareDist = e.global_position.distance_squared_to(char_global)
		if eSquareDist < lowestSquareDist:
			lowestSquareDist = eSquareDist
	return sqrt(lowestSquareDist)


func _on_exit_zone_body_entered(body: Node3D) -> void:
	if body != character:
		return
	if !_state == SceneStates.STICKER_PLACED:
		return
	level_won.emit()
	_state = SceneStates.DONE
	pass # Replace with function body.


func _on_character_bumped_object() -> void:
	#print("bump!")
	if _bump_cooldown <= 0:
		#print("bump (real)")
		_bump_cooldown = _bump_interval
	else:
		return
	for e in enforcers:
		e.investigate_this(character.global_position)
	pass # Replace with function body.


func _on_character_hit_by_enforcer() -> void:
	
	if _state == SceneStates.STICKER_PLACED:
		# YOU LOSE!
		level_lost.emit()
		print("you got got!")
	pass # Replace with function body.


func _on_enforcer_state_changed() -> void:
	if _state != SceneStates.STICKER_PLACED:
		pass
	
	var most_danger: Enforcer.DangerState = Enforcer.DangerState.SAFE
	for e in enforcers:
		match e.get_danger_state():
			Enforcer.DangerState.SAFE:
				continue
			Enforcer.DangerState.MID:
				most_danger = Enforcer.DangerState.MID
				continue
			Enforcer.DangerState.HIGH:
				most_danger = Enforcer.DangerState.HIGH
				break
	
	match most_danger:
		Enforcer.DangerState.SAFE:
			drumLooper.drum_state = DrumLooper.DrumStates.LOOP0
		Enforcer.DangerState.MID:
			drumLooper.drum_state = DrumLooper.DrumStates.LOOP1
		Enforcer.DangerState.HIGH:
			drumLooper.drum_state = DrumLooper.DrumStates.LOOP2
	
	#if enforcers.any(func(e): return e.is_danger_state()):
		#drumLooper.drum_state = DrumLooper.DrumStates.LOOP2
	#else:
		#drumLooper.drum_state = DrumLooper.DrumStates.LOOP1
		#pass
	
	pass
