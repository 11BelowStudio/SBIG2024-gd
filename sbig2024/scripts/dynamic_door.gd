
class_name DynamicDoor
extends Node3D

@onready var _hinge: HingeJoint3D = $HingeJoint3D
@onready var _anchor: StaticBody3D = $door_anchor
@onready var _door: RigidBody3D = $door_dynamic/Node/door

## set this to lock/unlock the door as needed
@export var door_state: DoorStates = DoorStates.LOCKED:
	set(value):
		door_state = value
		_on_update_door_state(value)

enum DoorStates {LOCKED, OPEN}

func _on_update_door_state(newState: DoorStates) -> void:
	
	if _hinge:
		_hinge.set_flag(HingeJoint3D.FLAG_USE_LIMIT, newState == DoorStates.LOCKED)
	if _door:
		if newState == DoorStates.LOCKED:
			_door.mass = 100
		else:
			_door.mass = 0.1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_update_door_state(door_state)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
