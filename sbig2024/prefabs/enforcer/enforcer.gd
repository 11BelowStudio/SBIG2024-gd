class_name Enforcer
extends CharacterBody3D

# now uses some nav agent code from the godot documentation
# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_introduction_3d.html#setup-for-3d-scene
# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html#actor-as-characterbody3d

var _target: Node3D

@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D

@export var _moveSpeed: float = 3
@export var _rotateSpeed: float = 60

## propagates the nav agent's navigation_finished signal upwards or something
signal navigation_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	_nav_agent.path_desired_distance = 0.5
	_nav_agent.target_desired_distance = 0.25
	
	# calls _on_velocity_computed whenever the nav agent's velocity is computed
	_nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	
	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	pass

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	# Now that the navigation map is no longer empty, set the movement target.
	if _target:
		set_movement_target(_target.global_position)

## give a node as a target
func set_target(target: Node3D):
	_target = target
	set_movement_target(_target.global_position)

func set_movement_target(movement_target: Vector3):
	_nav_agent.set_target_position(movement_target)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	
	if _target:
		if _target.global_position != _nav_agent.target_position:
			set_movement_target(_target.global_position)
	
	if _nav_agent.is_navigation_finished():
		#print("navigation is finished!")
		return
	
	var current_pos_g: Vector3 = global_position
	var next_position_g: Vector3 = _nav_agent.get_next_path_position()
	
	#next_position_g.y -= NavigationServer3D.map_get_cell_height(NavigationServer3D.agent_get_map(_nav_agent))
	
	var new_velocity: Vector3 = current_pos_g.direction_to(
		next_position_g
	) * _moveSpeed
	
	#print("c%s - n%s - v%s - d%s" % [current_pos_g, next_position_g, new_velocity, _nav_agent.target_position])
	
	if _nav_agent.avoidance_enabled:
		_nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	
	var offset: Vector3 = _nav_agent.get_next_path_position() - global_position
	offset.y = 0
	if offset != Vector3.ZERO:
		look_at(global_position + offset, Vector3.UP)
	
	
	#if _target:
	#
		#if _nav_agent.target_position != _target.position:
			#set_movement_target(_target.position)
		#
		#if _nav_agent.is_navigation_finished():
			#look_at(_nav_agent.target_position)
			#return
	#
	#if _target:
		#var target_pos: Vector3 = _target.position
		#
		#velocity = (Vector3.FORWARD * _moveSpeed).rotated(Vector3.UP, rotation.y)
	#
	#else:
		#velocity = Vector3.ZERO
	#
	#move_and_slide()
	
	

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	#print(velocity)
	move_and_slide()
	for col_idx in get_slide_collision_count():
		var col := get_slide_collision(col_idx)
		if col.get_collider() is RigidBody3D:
			var col2 = col.get_collider()
			col2.apply_central_impulse(-col.get_normal() * 0.3)
			col2.apply_impulse(-col.get_normal() * 0.01, col.get_position())
			if col2.has_method("bump"):
				col2.bump()

func _on_navigation_agent_3d_navigation_finished() -> void:
	#print("enforcer on navigation agent navigation finished")
	navigation_finished.emit()
	pass # Replace with function body.
