
class_name DynamicDoor
extends Node3D

@onready var _hinge: HingeJoint3D = $HingeJoint3D
@onready var _anchor: StaticBody3D = $door_anchor
@onready var _door: RigidBody3D = $door_dynamic/Node/door
@onready var _doorNoisePlayer: AudioStreamPlayer3D = %DoorNoisePlayer
@onready var _doorMesh = $door_dynamic/Node/door/door

## set this to lock/unlock the door as needed
@export var door_state: DoorStates = DoorStates.LOCKED:
	set(value):
		door_state = value
		_on_update_door_state(value)

enum DoorStates {LOCKED, OPEN}

@export_group("the material override")
@export var _doorMaterialOverride: BaseMaterial3D

func is_open() -> bool:
	return door_state == DoorStates.OPEN

func lock_door() -> void:
	door_state = DoorStates.LOCKED
	_on_update_door_state(DoorStates.LOCKED)

func open_door() -> void:
	door_state = DoorStates.OPEN
	_on_update_door_state(DoorStates.OPEN)

func set_open(open: bool) -> void:
	var new_state: DoorStates = DoorStates.LOCKED
	if open:
		new_state = DoorStates.OPEN
	door_state = new_state
	_on_update_door_state(new_state)


func _on_update_door_state(newState: DoorStates) -> void:
	
	if _hinge:
		# _hinge.set_flag(HingeJoint3D.FLAG_USE_LIMIT, newState == DoorStates.LOCKED)
		if newState == DoorStates.LOCKED:
			#_hinge.PARAM_LIMIT_LOWER = 0
			_hinge.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, 0)
			_hinge.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, 0)
			pass
		else:
			_hinge.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, -90)
			_hinge.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, 90)
			pass
	if _door:
		if newState == DoorStates.LOCKED:
			_door.mass = 100
		else:
			_door.mass = 0.25


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if _doorMaterialOverride:
		_doorMesh.material_override = _doorMaterialOverride
	
	_on_update_door_state(door_state)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_door_bumped() -> void:
	if !_doorNoisePlayer.playing:
		_doorNoisePlayer.play()
	pass # Replace with function body.

func _on_door_body_entered(_body: Node) -> void:
	_on_door_bumped()
