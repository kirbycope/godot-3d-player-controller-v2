class_name Controls
extends CharacterBody3D

@export_group("CONFIG")
@export var enable_climbing: bool = false ## Enable climbing
@export var enable_crawling: bool = true ## Enable crawling
@export var enable_crouching: bool = true ## Enable crouching
@export var enable_double_jumping: bool = false ## Enable double jumping
@export var enable_driving: bool = false ## Enable driving
@export var enable_flying: bool = false ## Enable flying
@export var enable_hanging: bool = false ## Enable hanging
@export var enable_holding_objects: bool = false ## Enable holding objects
@export var enable_jumping: bool = true ## Enable jumping
@export var enable_kicking: bool = false ## Enable kicking
@export var enable_navigation: bool = false ## Enable navigation (pathfinding)
@export var enable_paragliding: bool = false ## Enable paragliding
@export var enable_punching: bool = false ## Enable punching
@export var enable_retical: bool = true ## Enable the rectical
@export var enable_rolling: bool = false ## Enable rolling
@export var enable_sliding: bool = true ## Enable sliding
@export var enable_sprinting: bool = true ## Enable sprinting
@export var enable_swimming: bool = true ## Enable swimming
@export var enable_throwing: bool = false ## Enable throwing objects
@export var lock_movement_x: bool = false ## Lock movement along the X axis
@export var lock_movement_y: bool = false ## Lock movement along the Y axis
@export var lock_movement_z: bool = false ## Lock movement along the Z axis
@export_group("SKELETON")
@export var bone_name_left_hand: String = "LeftHand" ## Name of the left hand bone in the skeleton
@export var bone_name_right_hand: String = "RightHand" ## Name of the right hand bone in the skeleton
@export_group("SPEED")
@export var speed_climbing: float = 1.0 ## Speed while climbing
@export var speed_crawling: float = 0.75 ## Speed while crawling
@export var speed_flying: float = 5.0 ## Speed while flying
@export var speed_hanging: float = 0.25 ## Speed while hanging (shimmying)
@export var speed_jumping: float = 4.5 ## Speed while jumping
@export var speed_paragliding: float = 2.0 ## Speed while paragliding
@export var speed_rolling: float = 2.0 ## Speed while rolling
@export var speed_running: float = 3.5 ## Speed while running
@export var speed_skateboarding: float = 4.0 ## Speed while skateboarding
@export var speed_sliding: float = 2.5 ## Speed while sliding
@export var speed_sprinting: float = 5.0 ## Speed while sprinting
@export var speed_swimming: float = 3.0 ## Speed while swimming
@export var speed_walking: float = 1.0 ## Speed while walking

var current_state: States.State ## The current state of the 
var previous_state: States.State ## The previous state of the 
var input_direction: Vector2 = Vector2.ZERO ## The direction of the player input (UP/DOWN, LEFT/RIGHT).
var is_animation_locked: bool = false ## Is the player's animation locked?
var is_climbing: bool = false ## Is the player climbing a surface?
var is_climbing_ladder: bool = false ## Is the player climbing a ladder?
var is_crawling: bool = false ## Is the player crawling?
var is_crouching: bool = false ## Is the player crouching?
var is_double_jumping: bool = false ## Is the player double jumping?
var is_driving: bool = false ## Is the player driving?
var is_falling: bool = false ## Is the player falling?
var is_flying: bool = false ## Is the player flying?
var is_hanging: bool = false ## Is the player hanging?
var is_holding_1h_left: bool = false ## Is the player holding a 1-handed tool or weapon with their left hand?
var is_swinging_1h_left: bool = false ## Is the player swinging a 1-handed tool or weapon with their left hand?
var is_holding_1h_right: bool = false ## Is the player holding a 1-handed tool or weapon with their right hand?
var is_swinging_1h_right: bool = false ## Is the player swinging a 1-handed tool or weapon with their right hand?
var is_holding_left: bool = false ## Is the player holding a ball with their left hand?
var is_throwing_left: bool = false ## Is the player throwing a ball with their left hand?
var is_holding_right: bool = false ## Is the player holding a ball with their right hand?
var is_throwing_right: bool = false ## Is the player throwing a ball with their right hand?
var is_holding_fishing_rod: bool = false ## Is the player wielding a fishing rod?
var is_casting_fishing: bool = false ## Is the player casting a fishing line?
var is_reeling_fishing: bool = false ## Is the player reeling in a fishing line?
var is_holding_rifle: bool = false ## Is the player wielding a rifle?
var is_aiming_rifle: bool = false ## Is the player aiming a rifle?
var is_firing_rifle: bool = false ## Is the player firing a rifle?
var is_jumping: bool = false ## Is the player jumping?
var is_kicking_left: bool = false ## Is the player kicking with their left foot?
var is_kicking_right: bool = false ## Is the player kicking with their right foot?
var is_navigating: bool = false ## Is the player navigating?
var is_paragliding: bool = false ## Is the player paragliding?
var is_punching_left: bool = false ## Is the player punching with thier left hand?
var is_punching_right: bool = false ## Is the player punching with their right hand?
var is_reacting_low_left: bool = false ## Is the player reacting to being hit from the low left?
var is_reacting_low_right: bool = false ## Is the player reacting to being hit from the low right?
var is_reacting_high_left: bool = false ## Is the player reacting to being hit from the high left?
var is_reacting_high_right: bool = false ## Is the player reacting to being hit from the high right?
var is_rolling: bool = false ## Is the player rolling?
var is_running: bool = false ## Is the player running?
var is_skateboarding: bool = false ## Is the player skateboarding?
var is_sliding: bool = false ## Is the player sliding?
var is_standing: bool = false ## Is the player standing?
var is_sprinting: bool = false ## Is the player sprinting?
var is_swimming: bool = false ## Is the player swimming?
var is_swimming_in ## The water body the player is swimming in (if any)
var is_swinging_1h: bool = false ## Is the player swinging a 1-handed tool or weapon?
var is_throwing: bool = false ## Is the player throwing an object?
var is_walking: bool = false ## Is the player walking?
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") ## Default gravity value
var gravitating_towards ## The Node the player is being pulled towards (if any)
var speed_current: float = 0.0 ## Current speed
var virtual_velocity: Vector3 = Vector3.ZERO ## The player's velocity is movement were unlocked

@onready var animation_player: AnimationPlayer = $Visuals/Godette/AnimationPlayer
@onready var base_state: BaseState = $States/Base
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var collision_height: float  = collision_shape.shape.height
@onready var collision_width: float  = collision_shape.shape.radius * 2
@onready var collision_position: Vector3  = collision_shape.position
@onready var camera_mount = $CameraMount
@onready var spring_arm = camera_mount.get_node("CameraSpringArm")
@onready var camera = spring_arm.get_node("Camera3D")
@onready var controls = $Controls
@onready var debug = $Debug
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var pause: CanvasLayer = $Pause
@onready var visuals = $Visuals
@onready var ray_cast_jump_target: RayCast3D = visuals.get_node("RayCast3D_JumpTarget")
@onready var ray_cast_top: RayCast3D = visuals.get_node("RayCast3D_Top")
@onready var ray_cast_high: RayCast3D = visuals.get_node("RayCast3D_High")
@onready var ray_cast_middle: RayCast3D = visuals.get_node("RayCast3D_Middle")
@onready var ray_cast_low: RayCast3D = visuals.get_node("RayCast3D_Low")
@onready var skeleton: Skeleton3D = %GeneralSkeleton


## Called when the node is "ready", i.e. when both the node and its children have entered the scene tree.
func _ready() -> void:
	$States/Standing.start()


## Called when there is an input event.
func _input(event) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if pause.visible: return

	# Ⓨ/[Ctrl] press to drive vehicle - Exit vehicle
	if is_driving:
		if event.is_action_pressed(controls.button_3):
			base_state.transition_state(current_state, States.State.STANDING)
		else:
			return

	# [Left Mouse Button] _pressed_ -> Start "navigating"
	if enable_navigation:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
		and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			# Find out where to click
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * 10000
			var cursor_position = Plane(up_direction, transform.origin.y).intersects_ray(from, to)
			if cursor_position:
				#debug.draw_red_sphere(cursor_position) ## DEBUGGING
				navigation_agent.target_position = cursor_position
				if not is_navigating:
					base_state.transition_state(current_state, States.State.NAVIGATING)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Rotate the player to align with the current "up direction"
	var target_basis = Basis()
	target_basis.y = up_direction
	target_basis.x = - transform.basis.z.cross(up_direction).normalized()
	target_basis.z = target_basis.x.cross(up_direction).normalized()
	target_basis = target_basis.orthonormalized()
	transform.basis = target_basis


## Called once on each physics tick, and allows Nodes to synchronize their logic with physics ticks.
func _physics_process(delta) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the player's animation is locked
	if is_animation_locked: return

	# Skip movement processing while "driving"
	if is_driving: return

	# Calculate movement if not navigating
	if not is_navigating:
		# Determine the gravity direction and the new up_direction
		var gravity_direction: Vector3
		var new_up: Vector3
		var gravity_accel: Vector3
		# Check if using local gravity (e.g. planet)
		if gravitating_towards:
			gravity_direction = (gravitating_towards.global_position - global_position).normalized()
			new_up = - gravity_direction
			gravity_accel = gravity_direction * gravity
		# Otherwise use global gravity
		else:
			gravity_direction = - Vector3.UP
			new_up = Vector3.UP
			gravity_accel = - Vector3.UP * gravity

		if pause.visible:
			input_direction = Vector2.ZERO
		else:
			# Get the input vector by specifying four actions for the positive and negative X and Y axes
			input_direction = Input.get_vector(
				controls.move_left,
				controls.move_right,
				controls.move_up,
				controls.move_down,
			)

		# Handle player input for lateral movement (disabled while climbing/hanging)
		if not pause.visible \
		and not is_climbing \
		and not is_climbing_ladder \
		and not is_hanging:
			# Set the player's movement speed based on the input magnitude
			if speed_current == 0.0 and input_direction != Vector2.ZERO:
				# Use threshold-based speed selection for analog input
				# This ensures controller analog input triggers proper state transitions
				var input_magnitude = input_direction.length()
				if input_magnitude >= 0.5:  # Analog stick pushed more than halfway = run speed
					speed_current = speed_running
				else:  # Light analog stick movement = walk speed
					speed_current = speed_walking
			# Convert the 2D input into a 3D world-space direction and project onto the tangent plane (orthogonal to new_up)
			var raw_dir: Vector3 = transform.basis * Vector3(input_direction.x, 0, input_direction.y)
			var lateral_dir: Vector3 = raw_dir - new_up * raw_dir.dot(new_up)
			lateral_dir = lateral_dir.normalized()
			if lateral_dir:
				# Compute desired tangential (horizontal) velocity on the surface
				var tangential_velocity: Vector3 = lateral_dir * speed_current
				# Preserve current vertical speed along the NEW up direction
				var vertical_speed: float = velocity.dot(new_up)
				# Combine to form the new velocity
				velocity = tangential_velocity + new_up * vertical_speed
				# Check for conditions to update the visuals' facing direction
				if camera.perspective == camera.Perspective.THIRD_PERSON \
				and not is_climbing \
				and not is_climbing_ladder \
				and not is_hanging:
					# Update the visuals to look in the direction based on player input
					visuals.look_at(position + lateral_dir, new_up)

		# If flying and no input, stop lateral movement
		if is_flying and input_direction == Vector2.ZERO:
			# Zero out lateral velocity, preserve vertical
			var vertical_speed = velocity.dot(new_up)
			velocity = new_up * vertical_speed

		# If swimming and no input, stop lateral movement
		if is_swimming and input_direction == Vector2.ZERO:
			# Zero out lateral velocity, preserve vertical
			var vertical_speed = velocity.dot(new_up)
			velocity = new_up * vertical_speed

		# If skateboarding and no input, apply friction to slow down
		if is_skateboarding and input_direction == Vector2.ZERO:
				# Define friction coefficient (adjust this value to control how quickly the player slows down)
				var friction_coefficient = 0.95  # Higher value = slower deceleration (0.9-0.98 recommended)
				# Get the lateral (horizontal) velocity component
				var vertical_speed = velocity.dot(new_up)
				var lateral_velocity = velocity - new_up * vertical_speed
				# Apply friction to lateral velocity
				lateral_velocity *= friction_coefficient
				# If velocity is very low, stop completely
				if lateral_velocity.length() < 0.1:
					lateral_velocity = Vector3.ZERO
				# Recombine lateral and vertical components
				velocity = lateral_velocity + new_up * vertical_speed

		# Apply gravity for this tick (disabled while climbing or hanging)
		if not is_climbing \
		and not is_climbing_ladder \
		and not is_hanging:
			velocity += gravity_accel * delta
		# Commit the new up direction after applying gravity
		up_direction = new_up

	# Record the player's "virtual velocity"
	virtual_velocity = velocity

	# Apply movement locks
	if lock_movement_x:
		velocity.x = 0.0
	if lock_movement_y:
		velocity.y = 0.0
	if lock_movement_z:
		velocity.z = 0.0

	# Move the body based on velocity
	move_and_slide()


@rpc("any_peer", "call_local")
func animate_hit_low_left() -> void:
	is_reacting_low_left = true
	base_state.transition_state(current_state, States.State.REACTING)


@rpc("any_peer", "call_local")
func animate_hit_low_right() -> void:
	is_reacting_low_right = true
	base_state.transition_state(current_state, States.State.REACTING)


@rpc("any_peer", "call_local")
func animate_hit_high_left() -> void:
	is_reacting_high_left = true
	base_state.transition_state(current_state, States.State.REACTING)


@rpc("any_peer", "call_local")
func animate_hit_high_right() -> void:
	is_reacting_high_right = true
	base_state.transition_state(current_state, States.State.REACTING)


## Provides movement logic for climbing and hanging states; which are mostly skipped in _physics_process().
func move_player() -> void:
	# Get the collision normal (wall outward direction)
	var collision_normal_normalized: Vector3 = ray_cast_high.get_collision_normal().normalized()

	# Build an orthonormal basis for the wall plane using player's up and wall normal
	# Remove any component of up along the normal to get the wall-up (shimmy) axis
	var wall_up: Vector3 = (up_direction - collision_normal_normalized * up_direction.dot(collision_normal_normalized)).normalized()
	# Right axis along the wall (perpendicular to wall_up and normal)
	var wall_right: Vector3 = wall_up.cross(collision_normal_normalized).normalized()

	# Gather inputs mapped onto wall axies
	var move_direction: Vector3 = Vector3.ZERO
	# Only apply horizontal movement if not climbing a ladder
	if not is_climbing_ladder:
		if Input.is_action_pressed(controls.move_left):
			move_direction -= wall_right
		if Input.is_action_pressed(controls.move_right):
			move_direction += wall_right
	# Only apply vertical movement if climbing (a surface or ladder)
	if is_climbing \
	or is_climbing_ladder:
		if Input.is_action_pressed(controls.move_up):
			move_direction += wall_up
		if Input.is_action_pressed(controls.move_down):
			move_direction -= wall_up

	# Normalize to keep diagonal speed consistent
	if move_direction.length() > 0.0:
		move_direction = move_direction.normalized()

	# Constrain velocity strictly to the wall plane, no motion into or away from the wall
	velocity = move_direction * speed_current

	# Ensure the visuals face the wall (optional subtle alignment)
	var wall_forward = -collision_normal_normalized
	# Project the forward onto the plane perpendicular to up to avoid pitching toward ground/ceiling
	wall_forward = (wall_forward - up_direction * wall_forward.dot(up_direction)).normalized()
	if wall_forward.length() > 0.0 and position != position + wall_forward:
		visuals.look_at(position + wall_forward, up_direction)


func move_to_ladder() -> void:
	# Get the collision point
	var collision_point = ray_cast_high.get_collision_point()

	# [DEBUG] Draw a debug sphere at the collision point
	#debug.draw_debug_sphere(collision_point, Color.RED)

	# Calculate the direction from the player to collision point
	var direction = (collision_point - position).normalized()

	# Calculate new point by moving back from point along the direction by the given player radius
	collision_point = collision_point - direction * collision_width

	# [DEBUG] Draw a debug sphere at the adjusted collision point
	#debug.draw_debug_sphere(collision_point, Color.YELLOW)

	# Find the center of the surface of the ladder
	var ladder_surface_center = camera.ray_cast.get_collider().global_transform.origin

	# Find out the direction the ladder is facing
	var ladder_forward = -camera.ray_cast.get_collider().global_transform.basis.z

	# Adjust the collision point to be centered on the ladder surface
	collision_point = ladder_surface_center - ladder_forward/3

	# Adjust the point relative to the player's height
	collision_point = Vector3(collision_point.x, position.y, collision_point.z)

	# Move the player to the collision point
	global_position = collision_point

	# [DEBUG] Draw a debug sphere at the collision point
	#debug.draw_debug_sphere(collision_point, Color.GREEN)

	# Make the player face the ladder while keeping upright (flatten onto plane perpendicular to up)
	if ladder_forward.length() > 0.0 and position != position + ladder_forward:
		visuals.look_at(position + ladder_forward, up_direction)


## Snaps the player to the wall they are climbing/hanging on.
func move_to_wall() -> void:
	# Get the collision point
	var collision_point = ray_cast_high.get_collision_point()

	# [DEBUG] Draw a debug sphere at the collision point
	#debug.draw_debug_sphere(collision_point, Color.RED)

	# Calculate the direction from the player to collision point
	var direction = (collision_point - position).normalized()

	# Calculate new point by moving back from point along the direction by the given player radius
	collision_point = collision_point - direction * collision_width

	# [DEBUG] Draw a debug sphere at the adjusted collision point
	#debug.draw_debug_sphere(collision_point, Color.YELLOW)

	# Adjust the point relative to the player's height
	collision_point = Vector3(collision_point.x, position.y, collision_point.z)

	# Move the player to the collision point
	global_position = collision_point

	# [DEBUG] Draw a debug sphere at the collision point
	#debug.draw_debug_sphere(collision_point, Color.GREEN)

	# Get the collision normal
	var collision_normal = ray_cast_high.get_collision_normal()

	# Calculate the wall direction
	var wall_direction = -collision_normal

	# Make the player face the wall while keeping upright (flatten onto plane perpendicular to up)
	wall_direction = (wall_direction - up_direction * wall_direction.dot(up_direction)).normalized()
	if wall_direction.length() > 0.0 and position != position + wall_direction:
		visuals.look_at(position + wall_direction, up_direction)


func play_locked_animation(animation_name: String) -> float:
	var current_state_name = base_state.get_state_name(current_state)
	var current_state_scene = get_parent().find_child(current_state_name)
	current_state_scene.process_mode = Node.PROCESS_MODE_DISABLED
	animation_player.play(animation_name)
	animation_player.connect("animation_finished", _on_locked_animation_finished)
	is_animation_locked = true
	return animation_player.current_animation_length


func _on_locked_animation_finished(animation_name: String) -> void:
	animation_player.disconnect("animation_finished", _on_locked_animation_finished)
	var current_state_name = base_state.get_state_name(current_state)
	var current_state_scene = get_parent().find_child(current_state_name)
	current_state_scene.process_mode = Node.PROCESS_MODE_INHERIT
	is_animation_locked = false
