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
@onready var _enforcerSpawn = %EnforcerSpawn

var theSticker: StickerBase

@onready var character: FPCharacter = $Character

@onready var ui: FPUI = $FPUI


@export var _instruction_1: String = "Act natural, walk up to the box, get it done."
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
	FLEE,
	DONE
}
var _state: SceneStates = SceneStates.SPAWNED

enum StickerStates { NOT_DONE, DOING, DONE }

var sticker_state: StickerStates = StickerStates.NOT_DONE

## all of the enforcers (like every one of them)
@onready var enforcers: Array[Enforcer] = __get_enforcers()

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
	

	level_won.emit()

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
	character.fov_intensity_target = _intensity
	ui.vignette_intensity(_intensity)
	
	pass





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
	pass # Replace with function body.
