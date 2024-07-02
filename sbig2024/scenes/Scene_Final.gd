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
	pass


func _physics_process(delta: float) -> void:
	
	#if _enforcer:
		#if _enforcerReachedMiddle:
			#pass
		#else:
			#if _enforcer.position.z <= apartment.enforcerMidHall.position.z:
				#_enforcerReachedMiddle = true
				#_enforcer._target = character
				#wNoiseControl.set_intensity01(1)
				#heartbeater.intensity = 1
	
	pass


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
	
	add_child(_enforcer)
	
	_enforcer.set_target(apartment.enforcerMidHall)
	#_enforcer._target = apartment.enforcerMidHall
	
	apartment.enforcerDoor.open_door()
	
	wNoiseControl.set_intensity01(0.75)
	heartbeater.intensity = 0.75
	
	pass # Replace with function body.


func _on_enforcer_navigation_finished() -> void:
	if _enforcerReachedMiddle:
		pass
	_enforcerReachedMiddle = true
	_enforcer.set_target(character)
	wNoiseControl.set_intensity01(1)
	heartbeater.intensity = 1


func _on_character_hit_by_enforcer() -> void:
	print("get dunked on")
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
	pass # Replace with function body.
