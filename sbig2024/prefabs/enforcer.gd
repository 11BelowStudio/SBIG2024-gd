class_name Enforcer
extends CharacterBody3D


var _target: Node3D

@export var _moveSpeed: float = 3
@export var _rotateSpeed: float = 60


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	
	if _target:
		var target_pos: Vector3 = _target.position
		
		look_at(target_pos)
		
		#var to_target: Vector3 = position.direction_to(target_pos)
		#var quat_current: Quaternion = Quaternion(transform.basis)
		
		#quat_current = quat_current.slerp(Quaternion.from_euler(to_target), delta)
		
		#transform.basis = Basis(quat_current)
		
		velocity = (Vector3.FORWARD * _moveSpeed).rotated(Vector3.UP, rotation.y)
	
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()
	
	for col_idx in get_slide_collision_count():
		var col := get_slide_collision(col_idx)
		if col.get_collider() is RigidBody3D:
			var col2 = col.get_collider()
			col2.apply_central_impulse(-col.get_normal() * 0.3)
			col2.apply_impulse(-col.get_normal() * 0.01, col.get_position())
			if col2.has_method("bump"):
				col2.bump()
