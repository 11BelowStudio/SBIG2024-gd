class_name Enforcer
extends CharacterBody3D

# now uses some nav agent code from the godot documentation
# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_introduction_3d.html#setup-for-3d-scene
# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html#actor-as-characterbody3d

## navigation target for Giga Monty mode.
var _target_gm: Node3D

## what type of AI is this enforcer using?
enum AiType {
	## big dum, chases the player and nothing else (used in first and final scene)
	GIGA_MONTY,
	## May or may not end horribly.
	COMPLICATED
}

@export var ai_type: AiType = AiType.GIGA_MONTY

## given by the scene itself
var character: FPCharacter


@onready var detection_ray: RayCast3D = $DetectionRay

# the various states which may be used for complex mode
enum AiState {
	PATROL,
	INVESTIGATE,
	CHASE
}

@export var ai_state: AiState = AiState.PATROL

## The scene must give the enforcer all of the patrol nodes.
var _all_patrol_nodes: Array[EnforcerPatrolNode] = []
var _patrol_nodes_unvisited: Array[EnforcerPatrolNode] = []

func accept_all_patrol_nodes(scene_patrol_nodes: Array[EnforcerPatrolNode]) -> void:
	_all_patrol_nodes.append_array(scene_patrol_nodes)
	if _patrol_nodes_unvisited.is_empty():
		_patrol_nodes_unvisited.append_array(_all_patrol_nodes)


@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D

## move speed for Giga Monty mode
@export var _moveSpeed_gm: float = 4

## chase move speed for complicated mode
@export var _moveSpeed_chase: float = 6.5
## investigate move speed for complicated mode
@export var _moveSpeed_investigate: float = 6.5
## patrol move speed for complicated mode
@export var _moveSpeed_patrol: float = 3

var _chase_target: Node3D
var _patrol_global_position: Vector3 = Vector3.ZERO
var _patrol_next_global_position: Vector3 = Vector3.ZERO
var _patrol_new_next_pos_needed: bool = true
var _investigate_global_position: Vector3 = Vector3.ZERO

func move_speed() -> float:
	match ai_type:
		AiType.GIGA_MONTY:
			return _moveSpeed_gm
		AiType.COMPLICATED:
			match ai_state:
				AiState.PATROL:
					return _moveSpeed_patrol
				AiState.INVESTIGATE:
					return _moveSpeed_investigate
				AiState.CHASE:
					return _moveSpeed_chase
	return _moveSpeed_gm

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
	if _target_gm:
		set_movement_target(_target_gm.global_position)

## give a node as a target for Giga Monty mode
func set_target_gm(target: Node3D) -> void:
	_target_gm = target

## set a movement target
func set_movement_target(movement_target: Vector3):
	_nav_agent.set_target_position(movement_target)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _detection_ray_update() -> void:
	var character_head_global_offset: Vector3 = character.HEAD.global_position  - global_position
	detection_ray.look_at(global_position + character_head_global_offset)
	detection_ray.force_raycast_update()

## can the complex AI currently see the player?
func _can_see_player() -> bool:
	if !detection_ray.is_colliding():
		# nothing in the detection ray = player definitely isn't in the detection ray.
		return false
	var detected_object : CollisionObject3D = detection_ray.get_collider()
	return detected_object == character



func _complicated_chase_phys_update() -> void:
	if _can_see_player():
		_chase_target = character
		if _chase_target:
			
			_investigate_global_position = _chase_target.global_position
	else:
		ai_state = AiState.INVESTIGATE
		set_movement_target(_investigate_global_position)
	pass

func _complicated_investigate_phys_update() -> void:
	if _can_see_player():
		## start chasing if we can see the player
		ai_state = AiState.CHASE
		_chase_target = character
		_investigate_global_position = character.global_position
		set_movement_target(_chase_target.global_position)
	if _nav_agent.is_navigation_finished():
		# if reached target when investigating, go back to patrolling.
		ai_state = AiState.PATROL
		set_movement_target(_patrol_global_position)
	pass

func _complicated_patrol_phys_update() -> void:
	if _can_see_player():
		## start chasing if we can see the player
		ai_state = AiState.CHASE
		_chase_target = character
		_investigate_global_position = character.global_position
		set_movement_target(_chase_target.global_position)
	if _nav_agent.is_navigation_finished():
		# if reached current patrol target, go to the queued target.
		# indicate that we need to queue a new patrol target
		set_movement_target(_patrol_next_global_position)
		_patrol_new_next_pos_needed = true
	pass

func _complicated_chase_update() -> void:
	if !_chase_target.global_position.is_equal_approx(_nav_agent.target_position):
		set_movement_target(_chase_target.global_position)
	pass

func _complicated_investigate_update() -> void:
	pass


func _get_nearest_unvisited_patrol_node() -> EnforcerPatrolNode:
	var nearest: EnforcerPatrolNode = null
	var nearest_sq_dist: float = INF
	for pnode in _patrol_nodes_unvisited:
		var sq_dist: float = global_position.distance_squared_to(pnode.global_position)
		if sq_dist < nearest_sq_dist:
			nearest_sq_dist = sq_dist
			nearest = pnode
	return nearest

func _mark_nearby_patrol_nodes_as_visited(nearThisNode: EnforcerPatrolNode) -> void:
	var nearNodes: Array[EnforcerPatrolNode] = nearThisNode.get_nearby_nodes()
	nearNodes.append(nearThisNode)
	_patrol_nodes_unvisited = _patrol_nodes_unvisited.filter(
		func(pnode) : return pnode not in nearNodes
	)

func _complicated_patrol_update() -> void:
	
	if !_patrol_new_next_pos_needed:
		return
	if _patrol_nodes_unvisited.is_empty():
		_patrol_nodes_unvisited.append_array(_all_patrol_nodes)
		if _patrol_nodes_unvisited.is_empty():
			push_error("Cannot perform enforcer patrol update without any patrol nodes!")
			return
	
	var nearest_node: EnforcerPatrolNode = _get_nearest_unvisited_patrol_node()
	_mark_nearby_patrol_nodes_as_visited(nearest_node)
	_patrol_next_global_position = nearest_node.global_position
	_patrol_new_next_pos_needed = false
	
	pass



func _physics_process(delta: float) -> void:
	match ai_type:
		AiType.GIGA_MONTY:
			if _target_gm:
				if !_target_gm.global_position.is_equal_approx(_nav_agent.target_position):
					set_movement_target(_target_gm.global_position)
			if _nav_agent.is_navigation_finished():
				#print("navigation is finished!")
				return
			pass
		
		AiType.COMPLICATED:
			_detection_ray_update()
			match ai_state:
				AiState.CHASE:
					_complicated_chase_phys_update()
					pass
				AiState.PATROL:
					_complicated_patrol_phys_update()
					pass
				AiState.INVESTIGATE:
					_complicated_investigate_phys_update()
					pass
			pass
			if _nav_agent.is_navigation_finished():
				#print("navigation is finished!")
				return
			pass
	
	var current_pos_g: Vector3 = global_position
	var next_position_g: Vector3 = _nav_agent.get_next_path_position()
	
	#next_position_g.y -= NavigationServer3D.map_get_cell_height(NavigationServer3D.agent_get_map(_nav_agent))
	
	var new_velocity: Vector3 = current_pos_g.direction_to(
		next_position_g
	) * move_speed()
	
	#print("c%s - n%s - v%s - d%s" % [current_pos_g, next_position_g, new_velocity, _nav_agent.target_position])
	
	if _nav_agent.avoidance_enabled:
		_nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	
	var offset: Vector3 = _nav_agent.get_next_path_position() - global_position
	offset.y = 0
	if offset != Vector3.ZERO:
		look_at(global_position + offset, Vector3.UP)
	
	
	
	
	

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
