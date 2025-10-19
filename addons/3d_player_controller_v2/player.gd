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
@export var enable_punching: bool = false ## Enable punching
@export var enable_retical: bool = true ## Enable the rectical
@export var enable_rolling: bool = false ## Enable rolling
@export var enable_sliding: bool = true ## Enable sliding
@export var enable_skateboarding: bool = true ## Enable skateboarding
@export var enable_sprinting: bool = true ## Enable sprinting
@export var enable_swimming: bool = true ## Enable swimming
@export var lock_movement_x: bool = false ## Lock movement along the X axis
@export var lock_movement_y: bool = false ## Lock movement along the Y axis
@export var lock_movement_z: bool = false ## Lock movement along the Z axis
@export_group("SPEED")
@export var speed_climbing: float = 1.0 ## Speed while climbing
@export var speed_crawling: float = 0.75 ## Speed while crawling
@export var speed_flying: float = 5.0 ## Speed while flying
@export var speed_flying_fast: float = 10.0 ## Speed while flying fast
@export var speed_hanging: float = 0.25 ## Speed while hanging (shimmying)
@export var speed_jumping: float = 4.5 ## Speed while jumping
@export var speed_rolling: float = 2.0 ## Speed while rolling
@export var speed_running: float = 3.5 ## Speed while running
@export var speed_sliding: float = 2.5 ## Speed while sliding
@export var speed_sprinting: float = 5.0 ## Speed while sprinting
@export var speed_swimming: float = 3.0 ## Speed while swimming
@export var speed_walking: float = 1.0 ## Speed while walking

var current_state: States.State ## The current state of the player.
var input_direction: Vector2 = Vector2.ZERO ## The direction of the player input (UP/DOWN, LEFT/RIGHT).
var is_climbing: bool = false ## Is the player climbing?
var is_crawling: bool = false ## Is the player crawling?
var is_crouching: bool = false ## Is the player crouching?
var is_double_jumping: bool = false ## Is the player double jumping?
var is_driving: bool = false ## Is the player driving?
var is_falling: bool = false ## Is the player falling?
var is_flying: bool = false ## Is the player flying?
var is_hanging: bool = false ## Is the player hanging?
var is_jumping: bool = false ## Is the player jumping?
var is_kicking_left: bool = false ## Is the player kicking with their left foot?
var is_kicking_right: bool = false ## Is the player kicking with their right foot?
var is_navigating: bool = false ## Is the player navigating?
var is_punching_left: bool = false ## Is the player punching with thier left hand?
var is_punching_right: bool = false ## Is the player punching with their right hand?
var is_rolling: bool = false ## Is the player rolling?
var is_running: bool = false ## Is the player running?
var is_sliding: bool = false ## Is the player sliding?
var is_standing: bool = false ## Is the player standing?
var is_sprinting: bool = false ## Is the player sprinting?
var is_swimming: bool = false ## Is the player swimming?
var is_walking: bool = false ## Is the player walking?
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") ## Default gravity value
var gravitating_towards ## The Node the player is being pulled towards (if any)
var speed_current: float = 0.0 ## Current speed
var virtual_velocity: Vector3 = Vector3.ZERO ## The player's velocity is movement were unlocked

@onready var animation_player: AnimationPlayer = $Visuals/Godette/AnimationPlayer
@onready var base_state: BaseState = $States/Base
@onready var camera_mount = $CameraMount
@onready var spring_arm = camera_mount.get_node("CameraSpringArm")
@onready var camera = spring_arm.get_node("Camera3D")
@onready var controls = $Controls
@onready var debug = $Debug
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var pause: CanvasLayer = $Pause
@onready var visuals = $Visuals
@onready var ray_cast_top: RayCast3D = visuals.get_node("RayCast3D_Top")
@onready var ray_cast_high: RayCast3D = visuals.get_node("RayCast3D_High")
@onready var ray_cast_middle: RayCast3D = visuals.get_node("RayCast3D_Middle")
@onready var ray_cast_low: RayCast3D = visuals.get_node("RayCast3D_Low")


## Called when the node is "ready", i.e. when both the node and its children have entered the scene tree.
func _ready() -> void:
	# Start "standing"
	$States/Standing.start()


## Called when there is an input event.
func _input(event) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Handle inputs if not paused
	if not pause.visible:

		# 🄻1/[MB1] _pressed_ -> Start "punching left"
		if enable_punching:
			if event.is_action_pressed(controls.button_4) \
			and not is_punching_left \
			and not is_punching_right:
				base_state.transition_state(current_state, States.State.PUNCHING_LEFT)

		# 🅁1/[MB2] _pressed_ -> Start "punching right"
		if enable_punching:
			if event.is_action_pressed(controls.button_5) \
			and not is_punching_left \
			and not is_punching_right:
				base_state.transition_state(current_state, States.State.PUNCHING_RIGHT)

		# Ⓐ/[Space] _pressed_ and jumping is enabled -> Start "jumping"
		if enable_jumping:
			if event.is_action_pressed(controls.button_0) \
			and is_on_floor():
				base_state.transition_state(current_state, States.State.JUMPING)

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
					navigation_agent_3d.target_position = cursor_position
					if not is_navigating:
						# Start "navigating"
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

		# Handle player input for lateral movement (disabled while climbing/hanging)
		if not is_punching_left \
		and not is_punching_right \
		and not is_climbing \
		and not is_hanging:
			# Get the input vector by specifying four actions for the positive and negative X and Y axes
			input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
			# Set the player's movement speed based on the input magnitude
			if speed_current == 0.0 and input_direction != Vector2.ZERO:
				speed_current = input_direction.length() * speed_running
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
				and not is_hanging:
					# Update the visuals to look in the direction based on player input
					visuals.look_at(position + lateral_dir, new_up)

		# Apply gravity for this tick (disabled while climbing or hanging)
		if not is_climbing and not is_hanging:
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
