extends Node3D


@onready var character: FPCharacter = $Character
@onready var apartment: ApartmentHallScene = $ApartmentHallScene
@onready var heartbeater: Heartbeater = $Heartbeater
@onready var wNoiseControl: WhiteNoiseControl = $WhiteNoiseControl

@export var _enforcerScene: PackedScene
var _enforcer: Enforcer

var _enforcementInProgress: bool = false

var _enforcerReachedMiddle: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	_update_enforcer_dist_intensity()
	
	#print(_intensity)
	
	heartbeater.intensity_target = _enforcer_dist_intensity
	wNoiseControl.set_intensity01(_enforcer_dist_intensity)
	character.fov_intensity_target = _enforcer_dist_intensity
	apartment.fpui.vignette_intensity(_enforcer_dist_intensity)


func _on_apartment_hall_scene_player_hall_3() -> void:
	if _enforcementInProgress:
		return
	_enforcementInProgress = true
	
	_enforcer = _enforcerScene.instantiate()
	
	
	_enforcer.look_at_from_position(
		apartment.enforcerSpawn.position,
		apartment.enforcerMidHall.position,
		Vector3.UP
	)
	
	_enforcer.navigation_finished.connect(Callable(_on_enforcer_navigation_finished))
	
	_enforcer.ai_type = Enforcer.AiType.GIGA_MONTY
	
	add_child(_enforcer)
	
	_enforcer.set_target_gm(apartment.enforcerMidHall)
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
	print("get dunked on")
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
