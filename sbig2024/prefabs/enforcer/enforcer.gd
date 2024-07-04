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

@export var _ai_type: AiType = AiType.COMPLICATED

## given by the scene itself
@onready var character: FPCharacter = get_tree().get_first_node_in_group("character")

@onready var enforcerMoveNoise: AudioStreamPlayer3D = %EnforcerMoveNoise
@onready var passiveSource: AudioStreamPlayer3D = %PassiveSource
@onready var huntingSource: AudioStreamPlayer3D = %HuntingSource
@onready var aggroSource: AudioStreamPlayer3D = %AggroSource

@onready var glowingRedLight: SpotLight3D = %GlowingRedLight

@onready var whiteNoiseSource: AudioStreamPlayer3D = %WhiteNoise

@onready var detection_ray: RayCast3D = %DetectionRay
@onready var passive_mode_detection: RayCast3D = %PassiveModeDetection

## the various states which may be used for complex mode
enum AiState {
	PATROL,
	INVESTIGATE,
	CHASE
}

@export var _ai_state: AiState = AiState.PATROL

## An optional override for the enemy AI (in complicated mode).
## Giga Monty mode ignores these.
enum AiOverride {
	PASSIVE,
	AGGRESSIVE
}

## Override for the enemy AI in complicated mode (ignored by Giga Monty)
@export var _ai_override: AiOverride = AiOverride.PASSIVE

## The scene must give the enforcer all of the patrol nodes.
#@onready var _all_patrol_nodes: Array[EnforcerPatrolNode] = __get_patrol_nodes()
@onready var _patrol_nodes_unvisited: Array[EnforcerPatrolNode] = __get_patrol_nodes()

func __get_patrol_nodes() -> Array[EnforcerPatrolNode]:
	if is_node_ready():
		var result: Array[EnforcerPatrolNode] = []
		for n in get_tree().get_nodes_in_group("enforcer_patrol"):#.filter(func(n): return n is EnforcerPatrolNode) as Array[EnforcerPatrolNode]
			if n is EnforcerPatrolNode:
				result.append(n as EnforcerPatrolNode)
		return result
	else:
		push_error("cannot get patrol nodes whilst node isn't ready and such!")
		return []



@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D

@export var _detection_y_range: float = 45

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

var _can_set_target: bool = false
var _pre_physics_target: Vector3 = Vector3.INF

func move_speed() -> float:
	match _ai_type:
		AiType.GIGA_MONTY:
			return _moveSpeed_gm
		AiType.COMPLICATED:
			if _ai_override == AiOverride.PASSIVE:
				return _moveSpeed_patrol
			match _ai_state:
				AiState.PATROL:
					return _moveSpeed_patrol
				AiState.INVESTIGATE:
					return _moveSpeed_investigate
				AiState.CHASE:
					return _moveSpeed_chase
	return _moveSpeed_gm

## propagates the nav agent's navigation_finished signal upwards or something
signal navigation_finished

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	#_nav_agent.path_desired_distance = 0.5
	#_nav_agent.target_desired_distance = 0.25
	
	# calls _on_velocity_computed whenever the nav agent's velocity is computed
	_nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	
	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	
	init_ai(_ai_type, _ai_override, _ai_state)
	
	pass

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	_can_set_target = true
	# Now that the navigation map is no longer empty, set the movement target.
	
	if _pre_physics_target != Vector3.INF:
		set_movement_target(_pre_physics_target)
	
	if _ai_type == AiType.GIGA_MONTY:
		if _target_gm:
			set_movement_target(_target_gm.global_position)


func init_ai(ai_type: AiType, ai_override: AiOverride = AiOverride.PASSIVE, ai_state: AiState = AiState.PATROL):
	set_ai_type(ai_type)
	set_ai_override(ai_override)
	set_ai_state(ai_state)


func set_ai_type(new_ai_type: AiType) -> void:
	_ai_type = new_ai_type
	match _ai_type:
		AiType.GIGA_MONTY:
			if _target_gm:
				set_movement_target(_target_gm.global_position)
			__aggro_startup()
			if is_node_ready():
				aggroSource.play()
			pass
		AiType.COMPLICATED:
			set_ai_override(_ai_override)
			pass
	pass

func set_ai_state(new_ai_state: AiState) -> void:
	_ai_state = new_ai_state
	if _ai_type == AiType.GIGA_MONTY:
		return
	

func set_ai_override(new_ai_override: AiOverride) -> void:
	_ai_override = new_ai_override
	if _ai_type == AiType.GIGA_MONTY:
		return
	match _ai_override:
		AiOverride.PASSIVE:
			_ai_state = AiState.PATROL
			if is_node_ready():
				whiteNoiseSource.stop()
				glowingRedLight.visible = false
				aggroSource.stop()
				huntingSource.stop()
			pass
		AiOverride.AGGRESSIVE:
			__aggro_startup()
			pass
	pass


func __aggro_startup() -> void:
	if is_node_ready():
		whiteNoiseSource.play()
		glowingRedLight.visible = true
		passiveSource.stop()


## give a node as a target for Giga Monty mode
func set_target_gm(target: Node3D) -> void:
	_target_gm = target

## set a movement target
func set_movement_target(movement_target: Vector3):
	if _can_set_target:
		_nav_agent.set_target_position(movement_target)
	else:
		push_error("Attempted to set a movement target before physics had been sorted out!")
		_pre_physics_target = movement_target


func _detection_ray_update() -> void:
	var character_head_global_offset: Vector3 = character.HEAD.global_position  - global_position
	detection_ray.look_at(global_position + character_head_global_offset)
	detection_ray.rotation.y = clampf(detection_ray.rotation.y, -_detection_y_range, _detection_y_range)
	detection_ray.force_raycast_update()

## can the complex AI currently see the player?
func _can_see_player() -> bool:
	if !detection_ray.is_colliding():
		# nothing in the detection ray = player definitely isn't in the detection ray.
		return false
	var detected_object : CollisionObject3D = detection_ray.get_collider()
	return detected_object == character

## can the enforcer see the player but with the passive mode detection ray?
func _can_see_player_peaceful() -> bool:
	if !passive_mode_detection.is_colliding():
		# nothing in the detection ray = player definitely isn't in the detection ray.
		return false
	var detected_object : CollisionObject3D = passive_mode_detection.get_collider()
	return passive_mode_detection == character

func _complicated_chase_phys_update() -> void:
	if _can_see_player():
		_chase_target = character
		if _chase_target:
			_investigate_global_position = _chase_target.global_position
	else:
		_ai_state = AiState.INVESTIGATE
		set_movement_target(_investigate_global_position)
	pass

func _complicated_investigate_phys_update() -> void:
	if _can_see_player():
		## start chasing if we can see the player
		_ai_state = AiState.CHASE
		huntingSource.stop()
		aggroSource.play()
		_chase_target = character
		_investigate_global_position = character.global_position
		set_movement_target(_chase_target.global_position)
	if _nav_agent.is_navigation_finished():
		# if reached target when investigating, go back to patrolling.
		_ai_state = AiState.PATROL
		set_movement_target(_patrol_global_position)
	pass

func _complicated_patrol_phys_update() -> void:
	if _can_see_player() and _ai_override == AiOverride.AGGRESSIVE:
		## start chasing if we can see the player and we're in aggro mode
		_ai_state = AiState.CHASE
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
	if !_investigate_global_position != _nav_agent.target_position:
		set_movement_target(_investigate_global_position)
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
		#_patrol_nodes_unvisited.append_array(_all_patrol_nodes)
		_patrol_nodes_unvisited = __get_patrol_nodes()
		if _patrol_nodes_unvisited.is_empty():
			push_error("Cannot perform enforcer patrol update without any patrol nodes!")
			return
	
	var nearest_node: EnforcerPatrolNode = _get_nearest_unvisited_patrol_node()
	_mark_nearby_patrol_nodes_as_visited(nearest_node)
	_patrol_next_global_position = nearest_node.global_position
	_patrol_new_next_pos_needed = false
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	enforcerMoveNoise.volume_db = linear_to_db(velocity.length() / move_speed())
	
	match _ai_type:
		AiType.GIGA_MONTY:
			pass
		AiType.COMPLICATED:
			match _ai_override:
				AiOverride.PASSIVE:
					_complicated_patrol_update()
				AiOverride.AGGRESSIVE:
					match _ai_state:
						AiState.PATROL:
							_complicated_patrol_update()
						AiState.INVESTIGATE:
							_complicated_investigate_update()
						AiState.CHASE:
							_complicated_chase_update()
	
	pass


func _physics_process(delta: float) -> void:
	match _ai_type:
		AiType.GIGA_MONTY:
			if _target_gm:
				if !_target_gm.global_position.is_equal_approx(_nav_agent.target_position):
					set_movement_target(_target_gm.global_position)
			if _nav_agent.is_navigation_finished():
				#print("navigation is finished!")
				return
			pass
		
		AiType.COMPLICATED:
			match _ai_override:
				AiOverride.PASSIVE:
					if !passiveSource.playing:
						if _can_see_player_peaceful():
							passiveSource.play()
					_complicated_patrol_phys_update()
				AiOverride.AGGRESSIVE:
					_detection_ray_update()
					match _ai_state:
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
		#look_at(global_position + offset, Vector3.UP)
		
		global_transform.basis = global_transform.basis.slerp(
			global_transform.looking_at(_nav_agent.get_next_path_position(), Vector3.UP).basis,
		delta * 5)
		
		
	
	
	
	
	

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
