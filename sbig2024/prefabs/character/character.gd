
# COPYRIGHT Colormatic Studios
# MIT licence
# Quality Godot First Person Controller v2

# edited further by 11BelowStudio
class_name FPCharacter
extends CharacterBody3D

# TODO: Add descriptions for each value

@export_category("Flyposter variables")
@export var look_target: Node3D:
	set(value):
		look_target = value
		_look_target_dist = _get_target_dist()
		pass

## default value for look target dist when there's no target
const DEFAULT_NO_TARGET_DIST : float = -1

## distance between head and the look target
var _look_target_dist: float = DEFAULT_NO_TARGET_DIST

## 'intensity' of the look target distance
var _look_target_dist_intensity: float = 0

@export_range(0,1) var speed_intensity: float = 0:
	set(value):
		if value > 1:
			value = 1
		elif value < 0:
			value = 0
		speed_intensity = value

@onready var _base_speed: float = _calc_base_speed()
@export var _sprint_multiplier: float = 2
@export var _crouch_multiplier: float = 0.5

func _calc_base_speed() -> float:
	_base_speed = max_speed - (_speed_range * speed_intensity)
	return _base_speed

## obtains the appropriate speed for the player's current state
func _speed() -> float:
	match state:
		CharStates.NORMAL:
			return _base_speed
		CharStates.SPRINTING:
			return _base_speed * _sprint_multiplier
		CharStates.CROUCHING:
			return _base_speed * _crouch_multiplier
		_:
			return _base_speed

@export var min_speed: float = 0.25:
	set(value):
		min_speed = value
		_update_speed_range()
@export var max_speed: float = 3:
	set(value):
		max_speed = value
		_update_speed_range()
@onready var _speed_range: float = max_speed - min_speed
func _update_speed_range():
	_speed_range = max_speed - min_speed
	_calc_base_speed()

@export_range(0,1) var fov_intensity_target: float = 0:
	set(value):
		if value > 1:
			value = 1
		elif value < 0:
			value = 0
		fov_intensity_target = value
		_update_fov_target()

@export var real_fov_intensity: float:
	set(value):
		pass
	get:
		if !CAMERA:
			return fov_intensity_target
		var my_fov: float = CAMERA.fov
		if my_fov <= min_fov:
			return 0
		elif my_fov >= max_fov:
			return 1
		return 1 - ((my_fov - min_fov)/_fov_range)

@export_range(0,1) var _initial_fov_intensity: float = 0:
	set(value):
		if value > 1:
			value = 1
		elif value < 0:
			value = 0
		_initial_fov_intensity = value

@export var min_fov: float = 25:
	set(value):
		min_fov = value
		_update_fov_range()
@export var max_fov: float = 75:
	set(value):
		max_fov = value
		_update_fov_range()
@onready var _fov_range: float = max_fov - min_fov
func _update_fov_range():
	_fov_range = max_fov - min_fov
	_update_fov_target()

func _calc_fov_target(intensity: float) -> float:
	return max_fov - (_fov_range * intensity)

func _update_fov_target() -> float:
	target_fov = _calc_fov_target(fov_intensity_target)
	return target_fov
@onready var target_fov: float = _update_fov_target()


@export var min_modifier_dist: float = 3:
	set(value):
		min_modifier_dist = value
		_update_modifier_dist_range()
@export var max_modifier_dist: float = 10:
	set(value):
		max_modifier_dist = value
		_update_modifier_dist_range()
@onready var _modifier_dist_range: float = max_modifier_dist - min_modifier_dist
func _update_modifier_dist_range():
	_modifier_dist_range = max_modifier_dist - min_modifier_dist

@onready var _use_ray_cast: RayCast3D = $Head/UseRayCast

@export var use_ray_length: float = 3:
	set(value):
		use_ray_length = value
		if _use_ray_cast:
			_use_ray_cast.target_position = _use_ray_cast.target_position.normalized() * value
		pass


@onready var _held_sticker: MeshInstance3D = $Head/HeldSticker
@export var holding_sticker: bool = false:
	set(value):
		holding_sticker = value
		if _held_sticker:
			_held_sticker.visible = value

@export var capture_mouse: bool = true

signal hit_by_enforcer

signal bumped_object

@export_category("Character")
@export var base_speed : float = 3.0
@export var sprint_speed : float = 6.0
@export var crouch_speed : float = 1.0

@export var acceleration : float = 10.0
@export var jump_velocity : float = 4.5
@export var mouse_sensitivity : float = 0.1
@export var immobile : bool = false
@export_file var default_reticle

@export_group("Nodes")
@export var HEAD : Node3D
@export var CAMERA : Camera3D
@export var HEADBOB_ANIMATION : AnimationPlayer
@export var JUMP_ANIMATION : AnimationPlayer
@export var CROUCH_ANIMATION : AnimationPlayer
@export var COLLISION_MESH : CollisionShape3D

@export_group("Controls")
# We are using UI controls because they are built into Godot Engine so they can be used right away
@export var JUMP : String = "ui_accept"
@export var LEFT : String = "move_left"
@export var RIGHT : String = "move_right"
@export var FORWARD : String = "move_forward"
@export var BACKWARD : String = "move_back"
@export var PAUSE : String = "ui_cancel"
@export var CROUCH : String
@export var SPRINT : String = "sprint"

@export var LOOK_AROUND : String = "look"
@export var USE : String = "use"

# Uncomment if you want full controller support
#@export var LOOK_LEFT : String
#@export var LOOK_RIGHT : String
#@export var LOOK_UP : String
#@export var LOOK_DOWN : String

@export_group("Feature Settings")
@export var jumping_enabled : bool = false
@export var in_air_momentum : bool = true
@export var motion_smoothing : bool = true
@export var sprint_enabled : bool = false
@export var crouch_enabled : bool = false
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode : int = 0
@export_enum("Hold to Sprint", "Toggle Sprint") var sprint_mode : int = 0
@export var dynamic_fov_sprint : bool = false
@export var continuous_jumping : bool = true
@export var view_bobbing : bool = true
@export var jump_animation : bool = true
@export var pausing_enabled : bool = true
@export var gravity_enabled : bool = true


# Member variables
var speed : float = base_speed
var current_speed : float = 0.0
# States: normal, crouching, sprinting
enum CharStates { NORMAL, CROUCHING, SPRINTING }
var state : CharStates = CharStates.NORMAL
var low_ceiling : bool = false # This is for when the cieling is too low and the player needs to crouch.
var was_on_floor : bool = true # Was the player on the floor last frame (for landing animation)

# The reticle should always have a Control node as the root
var RETICLE : Control

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process


func _ready() -> void:
	#It is safe to comment this line if your game doesn't start with the mouse captured
	if capture_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	use_ray_length = use_ray_length
	holding_sticker = holding_sticker
	
	# If the controller is rotated in a certain direction for game design purposes,
	# redirect this rotation into the head.
	HEAD.rotation.y = rotation.y
	rotation.y = 0
	
	if default_reticle:
		change_reticle(default_reticle)
	
	# Reset the camera position
	# If you want to change the default head height, change these animations.
	HEADBOB_ANIMATION.play("RESET")
	JUMP_ANIMATION.play("RESET")
	CROUCH_ANIMATION.play("RESET")
	
	check_controls()
	
	CAMERA.fov = _calc_fov_target(_initial_fov_intensity)

func check_controls() -> void: # If you add a control, you might want to add a check for it here.
	if !InputMap.has_action(JUMP):
		push_error("No control mapped for jumping. Please add an input map control. Disabling jump.")
		jumping_enabled = false
	if !InputMap.has_action(LEFT):
		push_error("No control mapped for move left. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(RIGHT):
		push_error("No control mapped for move right. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(FORWARD):
		push_error("No control mapped for move forward. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(BACKWARD):
		push_error("No control mapped for move backward. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(PAUSE):
		push_error("No control mapped for move pause. Please add an input map control. Disabling pausing.")
		pausing_enabled = false
	if !InputMap.has_action(CROUCH):
		push_error("No control mapped for crouch. Please add an input map control. Disabling crouching.")
		crouch_enabled = false
	if !InputMap.has_action(SPRINT):
		push_error("No control mapped for sprint. Please add an input map control. Disabling sprinting.")
		sprint_enabled = false


func change_reticle(reticle) -> void: # Yup, this function is kinda strange
	if RETICLE:
		RETICLE.queue_free()
	
	RETICLE = load(reticle).instantiate()
	RETICLE.character = self
	$UserInterface.add_child(RETICLE)


func _calc_target_dist_intensity() -> void:
	if look_target:
		_look_target_dist = HEAD.global_position.distance_to(look_target.global_position)
		
		if _look_target_dist < max_modifier_dist:
			if _look_target_dist <= min_modifier_dist:
				_look_target_dist_intensity = 1
			else:
				_look_target_dist_intensity = 1 - ((_look_target_dist - min_modifier_dist)/_modifier_dist_range)
		else:
			_look_target_dist_intensity = 0
	else:
		_look_target_dist = DEFAULT_NO_TARGET_DIST
		_look_target_dist_intensity = 0


func get_target_dist() -> float:
	return _look_target_dist

func get_dist_intensity() -> float:
	return _look_target_dist_intensity


func _get_target_dist() -> float:
	if look_target:
		return HEAD.global_position.distance_to(look_target.global_position)
	else:
		return DEFAULT_NO_TARGET_DIST

func _do_look_target_dist_modifiers() -> void:
	if _look_target_dist == DEFAULT_NO_TARGET_DIST:
		_reset_look_target_dist_modifiers()
		return
	if _look_target_dist <= min_modifier_dist:
		speed = min_speed
		#target_fov = min_fov
	elif _look_target_dist >= max_modifier_dist:
		speed = max_speed
		#target_fov = max_fov
	else:
		var rawDistScaled = (_look_target_dist - min_modifier_dist)/_modifier_dist_range
		speed = min_speed + (_speed_range * rawDistScaled)
		#target_fov = min_fov + (_fov_range * rawDistScaled)
		
	pass

func _reset_look_target_dist_modifiers() -> void:
	speed = max_speed
	#target_fov = max_fov
	pass

func _physics_process(delta: float):
	# first things first - check if we have a look target,
	# then work out how close to the look target we are
	if look_target:
		#_look_target_dist = _get_target_dist()
		_calc_target_dist_intensity()
		# then we would modify some stats based on the look target dist
		_do_look_target_dist_modifiers()
	else:
		_look_target_dist = DEFAULT_NO_TARGET_DIST
		_look_target_dist_intensity = 0
		_reset_look_target_dist_modifiers()
	
	# Big thanks to github.com/LorenzoAncora for the concept of the improved debug values
	current_speed = Vector3.ZERO.distance_to(get_real_velocity())
	$UserInterface/DebugPanel.add_property("Speed", snappedf(current_speed, 0.001), 1)
	$UserInterface/DebugPanel.add_property("Target speed", _speed(), 2)
	var cv : Vector3 = get_real_velocity()
	var vd : Array[float] = [
		snappedf(cv.x, 0.001),
		snappedf(cv.y, 0.001),
		snappedf(cv.z, 0.001)
	]
	var readable_velocity : String = "X: " + str(vd[0]) + " Y: " + str(vd[1]) + " Z: " + str(vd[2])
	$UserInterface/DebugPanel.add_property("Velocity", readable_velocity, 3)
	
	# Gravity
	#gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # If the gravity changes during your game, uncomment this code
	if not is_on_floor() and gravity and gravity_enabled:
		velocity.y -= gravity * delta
	
	handle_jumping()
	
	var input_dir = Vector2.ZERO
	if !immobile: # Immobility works by interrupting user input, so other forces can still be applied to the player
		input_dir = Input.get_vector(LEFT, RIGHT, FORWARD, BACKWARD)
	handle_movement(delta, input_dir)
	
	# The player is not able to stand up if the ceiling is too low
	low_ceiling = $CrouchCeilingDetection.is_colliding()
	
	handle_state(input_dir)
	#if dynamic_fov_sprint: # This may be changed to an AnimationPlayer
		#update_camera_fov_sprint()
	
	if view_bobbing:
		headbob_animation(input_dir)
	
	#if Input.is_action_just_pressed(USE):
	#	_attempt_use()
	#	pass
	
	if jump_animation:
		if !was_on_floor and is_on_floor(): # The player just landed
			match randi() % 2: #TODO: Change this to detecting velocity direction
				0:
					JUMP_ANIMATION.play("land_left", 0.25)
				1:
					JUMP_ANIMATION.play("land_right", 0.25)
	
	was_on_floor = is_on_floor() # This must always be at the end of physics_process


func handle_jumping():
	if jumping_enabled:
		if continuous_jumping: # Hold down the jump button
			if Input.is_action_pressed(JUMP) and is_on_floor() and !low_ceiling:
				if jump_animation:
					JUMP_ANIMATION.play("jump", 0.25)
				velocity.y += jump_velocity # Adding instead of setting so jumping on slopes works properly
		else:
			if Input.is_action_just_pressed(JUMP) and is_on_floor() and !low_ceiling:
				if jump_animation:
					JUMP_ANIMATION.play("jump", 0.25)
				velocity.y += jump_velocity


func _bump_into_things() -> void:
	for col_idx in get_slide_collision_count():
		var col := get_slide_collision(col_idx)
		if col.get_collider() is RigidBody3D:
			var col2 = col.get_collider()
			col2.apply_central_impulse(-col.get_normal() * 0.3)
			col2.apply_impulse(-col.get_normal() * 0.01, col.get_position())
			if col2.has_method("bump"):
				col2.bump()
				bumped_object.emit()


func handle_movement(delta: float, input_dir: Vector2) -> void:
	var direction = input_dir.rotated(-HEAD.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	move_and_slide()
	_bump_into_things()
	
	var _currSpeed = _speed()
	if in_air_momentum:
		if is_on_floor():
			if motion_smoothing:
				velocity.x = lerp(velocity.x, direction.x * _currSpeed, acceleration * delta)
				velocity.z = lerp(velocity.z, direction.z * _currSpeed, acceleration * delta)
			else:
				velocity.x = direction.x * _currSpeed
				velocity.z = direction.z * _currSpeed
	else:
		if motion_smoothing:
			velocity.x = lerp(velocity.x, direction.x * _currSpeed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * _currSpeed, acceleration * delta)
		else:
			velocity.x = direction.x * _currSpeed
			velocity.z = direction.z * _currSpeed


func handle_state(input_dir: Vector2) -> void:
	if sprint_enabled:
		if sprint_mode == 0:
			if Input.is_action_pressed(SPRINT) and state != CharStates.CROUCHING:
				if input_dir:
					if state != CharStates.SPRINTING:
						enter_sprint_state()
				else:
					if state == CharStates.SPRINTING:
						enter_normal_state()
			elif state == CharStates.SPRINTING:
				enter_normal_state()
		elif sprint_mode == 1:
			if input_dir:
				# If the player is holding sprint before moving, handle that cenerio
				if Input.is_action_pressed(SPRINT) and state == CharStates.NORMAL:
					enter_sprint_state()
				if Input.is_action_just_pressed(SPRINT):
					match state:
						CharStates.NORMAL:
							enter_sprint_state()
						CharStates.SPRINTING:
							enter_normal_state()
			elif state == CharStates.SPRINTING:
				enter_normal_state()
	
	if crouch_enabled:
		if crouch_mode == 0:
			if Input.is_action_pressed(CROUCH) and state != CharStates.SPRINTING:
				if state != CharStates.CROUCHING:
					enter_crouch_state()
			elif state == CharStates.CROUCHING and !$CrouchCeilingDetection.is_colliding():
				enter_normal_state()
		elif crouch_mode == 1:
			if Input.is_action_just_pressed(CROUCH):
				match state:
					CharStates.NORMAL:
						enter_crouch_state()
					CharStates.CROUCHING:
						if !$CrouchCeilingDetection.is_colliding():
							enter_normal_state()


# Any enter state function should only be called once when you want to enter that state, not every frame.

func enter_normal_state() -> void:
	#print("entering normal state")
	var prev_state = state
	if prev_state == CharStates.CROUCHING:
		CROUCH_ANIMATION.play_backwards("crouch")
	state = CharStates.NORMAL
	speed = base_speed

func enter_crouch_state() -> void:
	#print("entering crouch state")
	var prev_state = state
	state = CharStates.CROUCHING
	speed = crouch_speed
	CROUCH_ANIMATION.play("crouch")

func enter_sprint_state() -> void:
	#print("entering sprint state")
	var prev_state = state
	if prev_state == CharStates.CROUCHING:
		CROUCH_ANIMATION.play_backwards("crouch")
	state = CharStates.SPRINTING
	speed = sprint_speed


func update_camera_fov_sprint() -> void:
	if state == CharStates.SPRINTING:
		CAMERA.fov = lerp(CAMERA.fov, 85.0, 0.3)
	else:
		CAMERA.fov = lerp(CAMERA.fov, 75.0, 0.3)


func update_camera_fov(target_fov: float, delta: float) -> void:
	CAMERA.fov = lerp(CAMERA.fov, target_fov, delta)
	pass

func headbob_animation(input_dir: Vector2) -> void:
	if input_dir and is_on_floor():
		var use_headbob_animation : String
		match state:
			CharStates.NORMAL,CharStates.CROUCHING:
				use_headbob_animation = "walk"
			CharStates.SPRINTING:
				use_headbob_animation = "sprint"
		
		var was_playing : bool = false
		if HEADBOB_ANIMATION.current_animation == use_headbob_animation:
			was_playing = true
		
		HEADBOB_ANIMATION.play(use_headbob_animation, 0.25)
		HEADBOB_ANIMATION.speed_scale = (current_speed / _base_speed) * 1.75
		if !was_playing:
			HEADBOB_ANIMATION.seek(float(randi() % 2)) # Randomize the initial headbob direction
			# Let me explain that piece of code because it looks like it does the opposite of what it actually does.
			# The headbob animation has two starting positions. One is at 0 and the other is at 1.
			# randi() % 2 returns either 0 or 1, and so the animation randomly starts at one of the starting positions.
			# This code is extremely performant but it makes no sense.
		
	else:
		if HEADBOB_ANIMATION.is_playing():
			HEADBOB_ANIMATION.play("RESET", 0.25)
			HEADBOB_ANIMATION.speed_scale = 1




func _process(delta: float) -> void:
	$UserInterface/DebugPanel.add_property("FPS", Performance.get_monitor(Performance.TIME_FPS), 0)
	var status : String = CharStates.keys()[state]
	if !is_on_floor():
		status += " in the air"
	$UserInterface/DebugPanel.add_property("State", status, 4)
	
	if pausing_enabled:
		if Input.is_action_just_pressed(PAUSE):
			match Input.mouse_mode:
				Input.MOUSE_MODE_CAPTURED:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				Input.MOUSE_MODE_VISIBLE:
					if capture_mouse:
						Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if look_target: # if we have a look target
		$UserInterface/DebugPanel.add_property("Target dist",_look_target_dist, 5)
		if (
			_look_target_dist < max_modifier_dist # if within range of the target
			and 
			!Input.is_action_pressed(LOOK_AROUND) # if 'LOOK AROUND' action not held
		):
			# look at the look target.
			
			#HEAD.look_at(look_target.global_position)
			
			HEAD.global_transform.basis = HEAD.global_transform.basis.slerp(
				HEAD.global_transform.looking_at(look_target.global_position, Vector3.UP).basis,
			delta * 5.0)
		else:
			# free look!
			pass
		
	
	HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	update_camera_fov(target_fov, delta)
	
	# Uncomment if you want full controller support
	#var controller_view_rotation = Input.get_vector(LOOK_LEFT, LOOK_RIGHT, LOOK_UP, LOOK_DOWN)
	#HEAD.rotation_degrees.y -= controller_view_rotation.x * 1.5
	#HEAD.rotation_degrees.x -= controller_view_rotation.y * 1.5


func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		HEAD.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		HEAD.rotation_degrees.x -= event.relative.y * mouse_sensitivity


## calls _use_ray_cast.get_collider()
func get_use_raycast_target() -> CollisionObject3D:
	_use_ray_cast.force_raycast_update()
	return _use_ray_cast.get_collider()

func _attempt_use() -> void:
	# TODO: do a raycast, probably just try signalling a 'use this' event on things it hits idk
	
	_use_ray_cast.force_raycast_update()
	
	if !_use_ray_cast.is_colliding():
		#print("nothing hit!")
		return
	
	var other: Object = _use_ray_cast.get_collider()
	#print("hit %s" % other)
	if other.has_method("use"):
		other.use()
	
	pass


func _on_enforcer_collision_area_body_entered(body: Node3D) -> void:
	#print("got hit by an enforcer!")
	hit_by_enforcer.emit()
	pass # Replace with function body.

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

