class_name FullScene
extends FPScene


@export var _instruction_1: String = "Act natural, walk up to the box, get it done."
@export var _instruction_2: String = "Get a bit closer, keep an eye out for enforcers (Q)..."
@export var _instruction_3: String = "Hold E to stick."
@export var _instruction_4: String = "Keep calm, walk away, act natural..."

@onready var heartbeater: Heartbeater = %Heartbeater
@onready var whitenoise: WhiteNoiseControl = %WhiteNoiseControl
@onready var dualAmbience: TwoTrackAmbience = %TwoTrackAmbience

@export var _enforcerScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	theSticker = %StickerPlace
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var char_intensity: float = character.get_dist_intensity()
	character.speed_intensity = char_intensity
	_update_enforcer_dist_intensity()
	
	_intensity = max(char_intensity, _enforcer_dist_intensity)
	#print(_intensity)
	
	heartbeater.intensity_target = _intensity
	dualAmbience.audio_weight_target = _intensity
	whitenoise.set_intensity01(_intensity)
	character.fov_intensity = _intensity
	
	match sticker_state:
		StickerStates.NOT_DONE:
			
			if char_intensity == 0:
				ui.show_instruction(_instruction_1)
			elif (char_intensity >= 0.35) and (char_intensity <= 0.8):
				ui.show_instruction(_instruction_2)
			
			sticker_progress = lerpf(sticker_progress, 0, sticker_decay_delta * delta)
			ui.progressBar().value = sticker_progress
		StickerStates.DOING:
			sticker_progress += delta
			ui.progressBar().value = sticker_progress
			if sticker_progress >= sticker_duration:
				sticker_done()
		_:
			pass
	pass

func sticker_done() -> void:
	theSticker.use()
	character.holding_sticker = false
	sticker_state = StickerStates.DONE
	heartbeater.intensity_target = 0
	dualAmbience.audio_weight_target = 0
	character.look_target = null
	ui.show_instruction(_instruction_4)


@export var enforcers: Array[Enforcer] = []

var _intensity: float = 0

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



func _on_character_hit_by_enforcer() -> void:
	level_lost.emit()
	pass # Replace with function body.
