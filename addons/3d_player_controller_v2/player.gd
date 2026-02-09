class_name Player
extends CharacterBody3D

## 3D player controller with state machine supporting climbing, combat, driving, swimming, and various movement modes

@export_group("CONFIG")
@export_enum("Mixamo", "Quaternius") var animation_set := 0 ## Animation set selection; 0=Mixamo, 1=Quaternius
@export var enable_climbing := false ## Enable climbing
@export var enable_crawling := false ## Enable crawling
@export var enable_crouching := false ## Enable crouching
@export var enable_double_jumping := false ## Enable double jumping
@export var enable_driving := false ## Enable driving
@export var enable_emotes := false ## Enable emotes
@export var enable_flipping := false ## Enable flipping
@export var enable_flying := false ## Enable flying
@export var enable_hanging := false ## Enable hanging
@export var enable_holding_objects := false ## Enable holding objects
@export var enable_jumping := false ## Enable jumping
@export var enable_kicking := false ## Enable kicking
@export var enable_mantling := false ## Enable mantling (ledge climbing)
@export var enable_navigation := false ## Enable navigation (pathfinding)
@export var enable_paragliding := false ## Enable paragliding
@export var enable_punching := false ## Enable punching
@export var enable_pushing := false ## Enable pushing
@export var enable_ragdolling := false ## Enable ragdoll physics
@export var enable_reticle := false ## Enable the reticle
@export var enable_rolling := false ## Enable rolling
@export var enable_sitting := false ## Enable sitting
@export var enable_sliding := false ## Enable sliding
@export var enable_sprinting := false ## Enable sprinting
@export var enable_strafing := false ## Enable strafing
@export var enable_swimming := false ## Enable swimming
@export var enable_throwing := false ## Enable throwing objects
@export var enable_vibration := false ## Enable controller vibration
@export var lock_movement_x := false ## Lock movement along the X axis
@export var lock_movement_y := false ## Lock movement along the Y axis
@export var lock_movement_z := false ## Lock movement along the Z axis
@export_group("SKELETON")
@export var bone_name_head := "Head" ## Name of the head bone in the skeleton
@export var bone_name_left_foot := "LeftFoot" ## Name of the left foot bone in the skeleton
@export var bone_name_right_foot := "RightFoot" ## Name of the right foot bone in the skeleton
@export var bone_name_left_hand := "LeftHand" ## Name of the left hand bone in the skeleton
@export var bone_name_right_hand := "RightHand" ## Name of the right hand bone in the skeleton
@export var head_look_target_offset := 1.65 ## Height above target origin to look at (in meters), defaults to player eye-line
@export_group("SPEED")
@export var playback_default_blend_time: float = 0.2
@export var speed_climbing := 1.0 ## Speed while climbing
@export var speed_crawling := 0.75 ## Speed while crawling
@export var speed_flying := 5.0 ## Speed while flying
@export var speed_hanging := 0.25 ## Speed while hanging (shimmying)
@export var speed_jumping := 4.5 ## Speed while jumping
@export var speed_paragliding := 2.0 ## Speed while paragliding
@export var speed_rolling := 2.0 ## Speed while rolling
@export var speed_running := 3.5 ## Speed while running
@export var speed_skateboarding := 4.0 ## Speed while skateboarding
@export var speed_sliding := 2.5 ## Speed while sliding
@export var speed_sprinting := 5.0 ## Speed while sprinting
@export var speed_swimming := 3.0 ## Speed while swimming
@export var speed_walking := 1.0 ## Speed while walking
@export_group("PHYSICS")
@export var force_pushing := 0.2 ## Force applied when pushing
@export var force_pushing_sprinting := 0.4 ## Force applied when pushing while sprinting

## -- STATE VARIABLES --
var current_state: States.State ## The current state of the player
var input_direction := Vector2.ZERO ## The direction of the player input (UP/DOWN, LEFT/RIGHT).
var is_animation_locked := false ## Is the player's animation locked?
var is_auto_running := false ## Is the player auto-running?
var is_blocking_1h_left := false ## Is the player blocking with a 1-handed tool or weapon with their left hand?
var is_blocking_1h_right := false ## Is the player blocking with a 1-handed tool or weapon with their right hand?
var is_blocking_2h := false ## Is the player blocking with a 2-handed tool or weapon?
var is_climbing := false ## Is the player climbing a surface?
var is_climbing_ladder := false ## Is the player climbing a ladder?
var is_crawling := false ## Is the player crawling?
var is_crouching := false ## Is the player crouching?
var is_double_jumping := false ## Is the player double jumping?
var is_driving := false ## Is the player driving?
var is_falling := false ## Is the player falling?
var is_flipping := false ## Is the player flipping?
var is_flying := false ## Is the player flying?
var is_hanging := false ## Is the player hanging?
var is_jumping := false ## Is the player jumping?
var is_kicking_left := false ## Is the player kicking with their left foot?
var is_kicking_right := false ## Is the player kicking with their right foot?
var is_mantling := false ## Is the player mantling (climbing up from a ledge)?
var is_navigating := false ## Is the player navigating?
var is_paragliding := false ## Is the player paragliding?
var is_punching_left := false ## Is the player punching with their left hand?
var is_punching_right := false ## Is the player punching with their right hand?
var is_pushing := false ## Is the player pushing?
var is_ragdolling := false ## Is the player ragdolling?
var is_reacting := false ## Is the player reacting to being hit?
var is_reacting_low_left := false ## Is the player reacting to being hit from the low left?
var is_reacting_low_right := false ## Is the player reacting to being hit from the low right?
var is_reacting_high_left := false ## Is the player reacting to being hit from the high left?
var is_reacting_high_right := false ## Is the player reacting to being hit from the high right?
var is_rolling := false ## Is the player rolling?
var is_running := false ## Is the player running?
var is_sitting := false ## Is the player sitting on a seat?
var is_skateboarding := false ## Is the player skateboarding?
var is_sliding := false ## Is the player sliding?
var is_sprinting := false ## Is the player sprinting?
var is_standing := false ## Is the player standing?
var is_strafing := false ## Is the player strafing?
var is_swimming := false ## Is the player swimming?
var is_throwing := false ## Is the player throwing an object?
var is_walking := false ## Is the player walking?
var previous_state: States.State ## The previous state of the player
var speed_current := 0.0 ## Current speed
var virtual_velocity := Vector3.ZERO ## The player's velocity is movement were unlocked
## -- ENVIRONMENT VARIABLES --
var gravitating_towards ## The Node the player is being pulled towards (if any)
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") ## Default gravity value
var swimming_in ## The body of water the player is swimming in (if any)
## -- EQUIPMENT VARIABLES --
var is_holding_1h_left := false ## Is the player holding a 1-handed tool or weapon with their left hand?
var is_swinging_1h_left := false ## Is the player swinging a 1-handed tool or weapon with their left hand?
var is_holding_1h_right := false ## Is the player holding a 1-handed tool or weapon with their right hand?
var is_swinging_1h_right := false ## Is the player swinging a 1-handed tool or weapon with their right hand?
var is_holding_2h := false ## Is the player holding a 2-handed tool or weapon?
var is_swinging_2h := false ## Is the player swinging a 2-handed tool or weapon?
var is_holding_left := false ## Is the player holding an object with their left hand?
var is_throwing_left := false ## Is the player throwing an object with their left hand?
var is_holding_right := false ## Is the player holding an object with their right hand?
var is_throwing_right := false ## Is the player throwing an object with their right hand?
var is_holding_fishing_rod := false ## Is the player wielding a fishing rod?
var is_casting_fishing := false ## Is the player casting a fishing line?
var is_reeling_fishing := false ## Is the player reeling in a fishing line?
var is_holding_rifle := false ## Is the player wielding a rifle?
var is_aiming_rifle := false ## Is the player aiming a rifle?
var is_firing_rifle := false ## Is the player firing a rifle?
## -- Character VARIABLES --
var animations_mixamo := false ## Are Mixamo animations enabled?
var animations_quaternius := false ## Are Quaternius animations enabled?
var animations_quaternius_2 := false ## Are Quaternius 2 animations enabled?
var setup_character: GDScript = preload("res://addons/3d_player_controller_v2/setup_character.gd")
var targets = {}
var current_focused_target: Node3D = null ## The current strafing focus target
var is_target_locked := false ## Is the player actively locked onto a target?
var head_look_modifiers := {} ## instance_id -> LookAtModifier3D, one per skeleton
var head_look_anchors := {} ## instance_id -> Node3D anchor used as target

@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var base_state: BaseState = $States/Base
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var collision_height: float = collision_shape.shape.height
@onready var collision_width: float = collision_shape.shape.radius * 2
@onready var collision_position: Vector3  = collision_shape.position
@onready var camera_mount = $CameraMount
@onready var character: Node3D = $Visuals/Character
@onready var character_animation_player_speed_scale := 1.0
@onready var spring_arm = camera_mount.get_node("CameraSpringArm")
@onready var camera = spring_arm.get_node("Camera3D")
@onready var chat = $Chat
@onready var controls = $Controls
@onready var debug = $Debug
@onready var emotes = $Emotes
@onready var focus_target_indicator: Node3D = $EnemyDetection/FocusTargetIndicator
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var pause: CanvasLayer = $Pause
@onready var timers: Node = $Timers
@onready var timer_kick_left = timers.get_node("KickLeft")
@onready var timer_kick_right = timers.get_node("KickRight")
@onready var timer_punch_left = timers.get_node("PunchLeft")
@onready var timer_punch_right = timers.get_node("PunchRight")
@onready var visuals = $Visuals
@onready var ray_cast_top: RayCast3D = visuals.get_node("RayCast3D_Top")
@onready var ray_cast_high: RayCast3D = visuals.get_node("RayCast3D_High")
@onready var ray_cast_middle: RayCast3D = visuals.get_node("RayCast3D_Middle")
@onready var ray_cast_low: RayCast3D = visuals.get_node("RayCast3D_Low")
@onready var ray_cast_below: RayCast3D = visuals.get_node("RayCast3D_Below")
@onready var shape_cast_jump_target: ShapeCast3D = visuals.get_node("ShapeCast3D_JumpTarget")
@onready var settings: CanvasLayer = $Settings


## Called when the node is "ready", i.e. when both the node and its children have entered the scene tree.
func _ready() -> void:
	# Setup animations for all `character` components
	setup_character.add_animations(character, self)

	_setup_head_look_at()

	# Initialize the state machine
	$States/Standing.start()


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if pause.visible: return

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

	# [Left Mouse Button] and [Right Mouse Button] _pressed_ -> Start "running"
	if event is InputEventMouseButton \
	and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
	and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) \
	and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		is_auto_running = true

	# [Left Mouse Button] and [Right Mouse Button] _released_ -> Start "running"
	if event is InputEventMouseButton \
	and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
	and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) \
	and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		is_auto_running = false


## Called once on each physics tick, and allows Nodes to synchronize their logic with physics ticks.
func _physics_process(delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the player's animation is locked
	if is_animation_locked: return

	# Skip movement processing while "driving"
	if is_driving: return

	# Skip movement processing while "ragdolling"
	if is_ragdolling: return

	# Skip movement processing while "sitting"
	if is_sitting: return

	var head_look_target: Node3D = null

	# Rotate the player to align with the current "up direction"
	var target_basis = Basis()
	target_basis.y = up_direction
	target_basis.x = - transform.basis.z.cross(up_direction).normalized()
	target_basis.z = target_basis.x.cross(up_direction).normalized()
	target_basis = target_basis.orthonormalized()
	transform.basis = target_basis

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

		# Zero out input direction if pause menu or chat input is visible
		if pause.visible \
		or chat.line_edit.visible:
			input_direction = Vector2.ZERO
		# Auto-run if both mouse buttons are held
		elif is_auto_running:
			input_direction = Vector2(0, -1)
		# Get the input vector by specifying four actions for the positive and negative X and Y axes
		else:
			input_direction = Input.get_vector(
				Controls.MOVE_LEFT,
				Controls.MOVE_RIGHT,
				Controls.MOVE_UP,
				Controls.MOVE_DOWN,
			)

		# Update strafing/backpedal flags and handle targeting
		if enable_strafing \
		and Input.is_action_pressed(Controls.BUTTON_6):
			# Holding the strafe button enables strafing, regardless of input magnitude
			is_strafing = true
			# Lock onto nearest target when button_6 is FIRST pressed
			if Input.is_action_just_pressed(Controls.BUTTON_6):
				var strafe_target = get_focus_target()
				if strafe_target:
					is_target_locked = true
			# Maintain lock or cancel if target is out of range
			if is_target_locked:
				var strafe_target = get_focus_target()
				if strafe_target:
					# Rotate to face the target while flattening the look vector onto the surface plane (avoid pitching down toward ground)
					look_at_flat_upright(self, strafe_target.global_position, new_up)
					look_at_flat_upright(visuals, strafe_target.global_position, new_up)
					look_at_flat_upright(camera_mount, strafe_target.global_position, new_up)
				head_look_target = strafe_target
			else:
				is_target_locked = false
		else:
			is_strafing = false
			# Reset target when button_6 is released
			if current_focused_target:
				_reset_target_material(current_focused_target)
				current_focused_target = null
			is_target_locked = false

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
				if input_magnitude >= 0.5: # Analog stick pushed more than halfway = run speed
					speed_current = speed_running
				else: # Light analog stick movement = walk speed
					speed_current = speed_walking
			# Convert the 2D input into a 3D world-space direction and project onto the tangent plane (orthogonal to new_up)
			var raw_dir: Vector3 = transform.basis * Vector3(input_direction.x, 0, input_direction.y)
			var lateral_dir: Vector3 = raw_dir - new_up * raw_dir.dot(new_up)
			lateral_dir = lateral_dir.normalized()
			# Handle strafing and "focus target" (if applicable)
			var strafe_target: Node3D = null
			# Keep the target reference while locked, even if not actively strafing, so we maintain facing when backpedaling
			if enable_strafing and is_target_locked:
				strafe_target = get_focus_target()
			# Only project movement onto a strafe tangent when there is horizontal input
			var has_strafe_input = abs(input_direction.x) > 0.1
			if strafe_target and is_strafing and has_strafe_input:
				var to_player = global_position - strafe_target.global_position
				to_player = to_player - new_up * to_player.dot(new_up)
				if to_player.length() > 0.001:
					var tangent = new_up.cross(to_player).normalized()
					if input_direction.x < 0.0:
						tangent = -tangent
					lateral_dir = tangent
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
					# Strafe/backpedal while facing the "focus target"
					if strafe_target:
						look_at_flat_upright(self, strafe_target.global_position, new_up)
						look_at_flat_upright(visuals, strafe_target.global_position, new_up)
						look_at_flat_upright(camera_mount, strafe_target.global_position, new_up)
					# Strafe using camera forward direction
					elif enable_strafing and is_strafing:
						var camera_forward: Vector3 = -camera.global_transform.basis.z
						camera_forward = (camera_forward - new_up * camera_forward.dot(new_up)).normalized()
						if camera_forward.length() > 0.001:
							visuals.look_at(position + camera_forward, new_up)
					# Face the movement direction
					else:
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

	_update_head_look_at(head_look_target)

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
	move(delta)


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


## Rotates a node toward a target while flattening pitch onto the plane defined by up (no looking down when above target).
func look_at_flat_upright(node: Node3D, target_position: Vector3, up: Vector3) -> void:
	var direction: Vector3 = target_position - node.global_position
	# Remove vertical component so the node stays upright relative to the surface normal
	direction -= up * direction.dot(up)
	if direction.length() > 0.001:
		node.look_at(node.global_position + direction, up)


func _setup_head_look_at() -> void:
	for skel in skeletons():
		var modifier := _ensure_head_modifier_for(skel)
		if modifier:
			head_look_modifiers[skel.get_instance_id()] = modifier


func _update_head_look_at(target: Node3D) -> void:
	for skel in skeletons():
		var modifier := _ensure_head_modifier_for(skel)
		if not modifier:
			continue
		var anchor := _ensure_head_anchor_for(skel)
		if not anchor:
			modifier.target_node = NodePath("")
			continue
		if target and is_instance_valid(target):
			anchor.global_position = target.global_transform.origin + up_direction * head_look_target_offset
			modifier.target_node = modifier.get_path_to(anchor)
		else:
			modifier.target_node = NodePath("")


func _ensure_head_modifier_for(skel: Skeleton3D) -> LookAtModifier3D:
	if not skel:
		return null
	var key = skel.get_instance_id()
	if key in head_look_modifiers:
		var cached: LookAtModifier3D = head_look_modifiers[key]
		if cached and is_instance_valid(cached):
			return cached
	# Try to find an existing one on the skeleton
	var existing: LookAtModifier3D = skel.get_node_or_null("HeadLookAt")
	if existing and is_instance_valid(existing):
		head_look_modifiers[key] = existing
		return existing
	# Create a new modifier
	var modifier := LookAtModifier3D.new()
	modifier.name = "HeadLookAt"
	modifier.bone_name = bone_name_head
	modifier.use_angle_limitation = true
	modifier.primary_limit_angle = deg_to_rad(80.0)
	modifier.secondary_limit_angle = deg_to_rad(60.0)
	modifier.relative = true
	modifier.use_secondary_rotation = true
	skel.add_child(modifier)
	head_look_modifiers[key] = modifier
	return modifier


func _ensure_head_anchor_for(skel: Skeleton3D) -> Node3D:
	if not skel:
		return null
	var key = skel.get_instance_id()
	if key in head_look_anchors:
		var cached: Node3D = head_look_anchors[key]
		if cached and is_instance_valid(cached):
			return cached
	var anchor := Node3D.new()
	anchor.name = "HeadLookTargetAnchor"
	skel.add_child(anchor)
	head_look_anchors[key] = anchor
	return anchor


## Returns the closest valid focus target, if any.
func get_focus_target() -> Node3D:
	# If player is actively locked onto a target, only check that target
	if is_target_locked:
		if current_focused_target and is_instance_valid(current_focused_target):
			# Check if the target is still in the targets dictionary (in range)
			var target_id = current_focused_target.get_instance_id()
			if target_id in targets:
				return current_focused_target
			else:
				# Target went out of range, cancel the lock
				_reset_target_material(current_focused_target)
				current_focused_target = null
				is_target_locked = false
				return null
		else:
			# Locked but no valid target, unlock
			is_target_locked = false
			return null
	
	# Search for a new target only if not currently locked
	var closest: Node3D = null
	var closest_distance_sq := INF
	for target in targets.values():
		if not is_instance_valid(target):
			continue
		var distance_sq = global_position.distance_squared_to(target.global_position)
		if distance_sq < closest_distance_sq:
			closest_distance_sq = distance_sq
			closest = target
	
	# Update focus target highlighting
	if closest != current_focused_target:
		if current_focused_target:
			_reset_target_material(current_focused_target)
		current_focused_target = closest
		if current_focused_target:
			_highlight_target_material(current_focused_target)
	
	return closest


## Connects a [Signal] (by name) to a [Callable] on all [AnimationPlayer] nodes found under [character] (recursively).
func animation_player_connect(_signal: String, callable: Callable) -> void:
	for animation_player in animation_players():
		if not animation_player.is_connected(_signal, callable):
			animation_player.connect(_signal, callable)


## Gets the _current animation_ name from the first [AnimationPlayer] node found as a child of [character].
func animation_player_current_animation() -> String:
	var animation_name: String = "" ## The key of the currently playing animation.
	for animation_player in animation_players():
		animation_name = animation_player.current_animation
		break
	return animation_name


## Get the length of the _current animation_ from the first [AnimationPlayer] node found as a child of [character].
func animation_player_current_animation_length() -> float:
	var animation_length: float = 0.0 ## The length (in seconds) of the currently playing animation.
	for animation_player in animation_players():
		animation_length = animation_player.current_animation_length
		break
	return animation_length


## Disconnects a [Signal] (by name) from a [Callable] on all [AnimationPlayer] nodes found under [character] (recursively).
func animation_player_disconnect(_signal: String, callable: Callable) -> void:
	for animation_player in animation_players():
		if animation_player.is_connected(_signal, callable):
			animation_player.disconnect(_signal, callable)


## Checks if a [Signal] (by name) is connected to a [Callable] on any [AnimationPlayer] nodes found under [character] (recursively).
func animation_player_is_connected(_signal: String, callable: Callable) -> bool:
	for animation_player in animation_players():
		if animation_player.is_connected(_signal, callable):
			return true
	return false


## Pauses all animations on all [AnimationPlayer] nodes found under [character] (recursively).
func animation_player_pause() -> void:
	for animation_player in animation_players():
		animation_player.call_deferred("pause")


## Plays an animation on all [AnimationPlayer] nodes found under [character] (recursively).
func animation_player_play(_name: StringName = &"", custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false) -> void:
	# Skip if no animation name was provided
	if _name == &"": return

	# Play the animation on each AnimationPlayer that has it
	for animation_player in animation_players():
		if animation_player.has_animation(_name):
			animation_player.call_deferred("play", _name, custom_blend, custom_speed, from_end)
		#else: push_warning("Animation '%s' not found on AnimationPlayer '%s'" % [name, animation_player.name]) ## DEBUGGING


## Plays an animation backwards on all [AnimationPlayer] nodes found under [character] (recursively).
func animation_player_play_backwards(_name: StringName = &"", custom_blend: float = -1) -> void:
	# Skip if no animation name was provided
	if _name == &"": return
	# Play the animation backwards on each AnimationPlayer that has it
	for animation_player in animation_players():
		if animation_player.has_animation(_name):
			animation_player.call_deferred("play_backwards", _name, custom_blend)
		#else: push_warning("Animation '%s' not found on AnimationPlayer '%s'" % [name, animation_player.name]) ## DEBUGGING


## Plays a locked animation that disables state processing until it finishes.
func animation_player_play_locked(_name: String, duration: float = -1.0) -> float:
	# Skip if no animation name was provided
	if _name == "": return 0.0

	# Ensure at least one AnimationPlayer has this animation before locking state
	var has_animation := false
	for animation_player in animation_players():
		if animation_player.has_animation(_name):
			has_animation = true
			break
	if not has_animation:
		push_warning("Animation '%s' not found on any AnimationPlayer" % _name)
		return 0.0

	var current_state_name = base_state.get_state_name(current_state)
	var current_state_scene = get_parent().find_child(current_state_name)
	current_state_scene.process_mode = Node.PROCESS_MODE_DISABLED
	if duration == -1.0:
		animation_player_play(_name)
	else:
		animation_player_play_section(_name, 0.0, duration)
	animation_player_connect("animation_finished", _on_locked_animation_finished)
	is_animation_locked = true
	return animation_player_current_animation_length()


## Plays a section of an animation on all [AnimationPlayer] nodes found under [character] (recursively).
func  animation_player_play_section(_name: StringName = &"", start_time: float = -1, end_time: float = -1, custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false) -> void:
	# Skip if no animation name was provided
	if _name == &"": return

	# Play the animation section on each AnimationPlayer that has it
	for animation_player in animation_players():
		if animation_player.has_animation(_name):
			animation_player.call_deferred("play_section", _name, start_time, end_time, custom_blend, custom_speed, from_end)


## Sets the _speed scale_ on all [AnimationPlayer] nodes found under [character] (recursively).
func animation_player_set_speed_scale(speed_scale: float) -> void:
	for animation_player in animation_players():
		animation_player.call_deferred("set_speed_scale", speed_scale)
		character_animation_player_speed_scale = speed_scale


## Stops all animations on all [AnimationPlayer] nodes found under [character] (recursively).
func animation_player_stop() -> void:
	for animation_player in animation_players():
		animation_player.call_deferred("stop")


## Gets all child [AnimationPlayer] nodes found under [character] (recursively).
func animation_players() -> Array:
	var animation_players: Array = []
	# Only continue if `character` is not null
	if character:
		# Search for all [AnimationPlayer] nodes under `character`
		var search_results = character.find_children("*", "AnimationPlayer", true, false)
		# Add each found node to the array
		for node in search_results:
			animation_players.append(node)
	#print("Found ", animation_players.size(), " AnimationPlayer(s) under `", character.get_path(), "`") # DEBUGGING
	return animation_players


## Applies an impact impulse to a collider at the specified bone's position.
func apply_impact(collider, bone_name, force_multiplier = 1.0) -> void:
	# Get the bone's global position
	var bone_position = global_position
	var bone_idx = skeleton().find_bone(bone_name)
	if bone_idx != -1:
		# Get the current global position of the bone
		bone_position = skeleton().to_global(skeleton().get_bone_global_pose(bone_idx).origin)

	# Calculate the direction from the bone to the collider's position
	var collider_position = collider.global_position
	collider_position = Vector3(
		collider_position.x,
		bone_position.y,
		collider_position.z,
	)
	var direction = (collider_position - bone_position).normalized()

	# Apply the impulse
	var impulse = direction * force_multiplier
	#collider.apply_impulse(impulse, collider_position)
	if collider is SoftBody3D \
	or collider is RigidBody3D:
		collider.apply_central_impulse(impulse)

	# Vibrate the controller, if enabled
	if enable_vibration \
	and controls.last_input_type == Controls.InputType.CONTROLLER:
		if force_multiplier <= 1.0:
			Input.start_joy_vibration(0, 1.0, 1.0, 0.1)
		else:
			Input.start_joy_vibration(0, 0.0, 1.0, 0.2)


## Applies impulse to colliders when sliding against them.
func handle_collisions() -> void:
	# Iterate through all slide collisions; from move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		# Handle RigidBody3D collisions
		if collider is RigidBody3D:
			var push_force = force_pushing_sprinting if is_sprinting else force_pushing
			var push_direction = collision.get_normal() * -1.0
			var velocity_factor = min(velocity.length(), 5.0)
			var impulse = push_direction * push_force * velocity_factor
			collider.apply_central_impulse(impulse)

		# Handle SoftBody3D collisions
		elif collider is SoftBody3D:
			var push_force = force_pushing_sprinting if is_sprinting else force_pushing
			var push_direction = collision.get_normal() * -1.0
			var velocity_factor = min(velocity.length(), 5.0)
			var impulse = push_direction * push_force * velocity_factor
			collider.apply_central_impulse(impulse)


## Moves the player while adhering to the current surface orientation.
func move(delta) -> void:
	# Use CharacterBody3D's built-in floor snapping for smooth slope traversal and step climbing
	# floor_snap_length helps climb small steps when combined with floor_constant_speed
	floor_snap_length = 0.5 if (input_direction != Vector2.ZERO and not is_skateboarding) else 0.0
	floor_stop_on_slope = true

	move_and_slide()

	# Handle collisions
	handle_collisions()


## Provides movement logic for climbing and hanging states; which are mostly skipped in _physics_process().
func move_player() -> void:
	# Get the collision normal (wall outward direction)
	var collision_normal_normalized: Vector3 = ray_cast_high.get_collision_normal().normalized()

	# Build an orthonormal basis for the wall plane using player's up and wall normal
	# Remove any component of up along the normal to get the wall-up (shimmy) axis
	var wall_up: Vector3 = (up_direction - collision_normal_normalized * up_direction.dot(collision_normal_normalized)).normalized()
	# Right axis along the wall (perpendicular to wall_up and normal)
	var wall_right: Vector3 = wall_up.cross(collision_normal_normalized).normalized()

	# Gather inputs mapped onto wall axis
	var move_direction: Vector3 = Vector3.ZERO
	# Only apply horizontal movement if not climbing a ladder
	if not is_climbing_ladder:
		if Input.is_action_pressed(Controls.MOVE_LEFT):
			move_direction -= wall_right
		if Input.is_action_pressed(Controls.MOVE_RIGHT):
			move_direction += wall_right
	# Only apply vertical movement if climbing (a surface or ladder)
	if is_climbing \
	or is_climbing_ladder:
		if Input.is_action_pressed(Controls.MOVE_UP):
			move_direction += wall_up
		if Input.is_action_pressed(Controls.MOVE_DOWN):
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


## Snaps the player to the middle of the ladder they are climbing.
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


## Snaps the player to the wall they are climbing on or hanging from.
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


## Gets the [PhysicalBoneSimulator3D] node from the player's [Skeleton3D].
func physical_bone_simulator() -> PhysicalBoneSimulator3D:
	var physical_bone_simulator: PhysicalBoneSimulator3D = null
	if skeleton():
		physical_bone_simulator = skeleton().get_node_or_null("PhysicalBoneSimulator3D")
	return physical_bone_simulator


## Gets the [Skeleton3D] node from the player's `$Character`.
func skeleton() -> Skeleton3D:
	var skeleton: Skeleton3D = null
	for child in character.get_children():
		# Only consider visible nodes to avoid getting wrong skeleton
		if child.visible:
			skeleton = child.get_node_or_null("%GeneralSkeleton")
			if skeleton:
				break
	return skeleton


func skeletons() -> Array:
	var list: Array = []
	for child in character.get_children():
		if not child.visible:
			continue
		var skel: Skeleton3D = child.get_node_or_null("%GeneralSkeleton")
		if skel:
			list.append(skel)
	return list


## Callback for when a locked animation finishes playing.
func _on_locked_animation_finished(animation_name: String) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	animation_player_disconnect("animation_finished", _on_locked_animation_finished)
	var current_state_name = base_state.get_state_name(current_state)
	var current_state_scene = get_parent().find_child(current_state_name)
	current_state_scene.process_mode = Node.PROCESS_MODE_INHERIT
	is_animation_locked = false


## Highlights a target by changing its FocusTargetIndicator to yellow.
func _highlight_target_material(target: Node3D) -> void:
	var indicator = target.get_node_or_null("FocusTargetIndicator")
	if indicator:
		var mesh_instance = indicator.get_node_or_null("MeshInstance3D")
		if mesh_instance and mesh_instance is MeshInstance3D:
			var current_material = mesh_instance.get_active_material(0)
			if current_material:
				var highlighted_material = current_material.duplicate()
				if highlighted_material is StandardMaterial3D:
					highlighted_material.albedo_color = Color.YELLOW
				mesh_instance.set_surface_override_material(0, highlighted_material)


## Resets a target's FocusTargetIndicator to white.
func _reset_target_material(target: Node3D) -> void:
	var indicator = target.get_node_or_null("FocusTargetIndicator")
	if indicator:
		var mesh_instance = indicator.get_node_or_null("MeshInstance3D")
		if mesh_instance and mesh_instance is MeshInstance3D:
			mesh_instance.set_surface_override_material(0, null)


func _on_kick_left_timeout() -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if not still kicking left
	if not is_kicking_left: return

	# Apply impact at bone position if colliding
	if ray_cast_low.is_colliding():
		var collider = ray_cast_low.get_collider()
		apply_impact(collider, bone_name_left_foot, 2.0)

		# Player Kicking Low Left -> Enemy Reacting Low Right
		if collider is CharacterBody3D \
		or collider is RigidBody3D \
		or collider is SoftBody3D:
			if collider.has_method("animate_hit_low_right"):
				collider.rpc("animate_hit_low_right", self)


func _on_kick_right_timeout() -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if not still kicking right
	if not is_kicking_right: return

	# Apply impact at bone position if colliding
	if ray_cast_low.is_colliding():
		var collider = ray_cast_low.get_collider()
		apply_impact(collider, bone_name_right_foot, 2.0)

		# Player Kicking Low Right -> Enemy Reacting Low Left
		if collider is CharacterBody3D \
		or collider is RigidBody3D \
		or collider is SoftBody3D:
			if collider.has_method("animate_hit_low_left"):
				collider.rpc("animate_hit_low_left", self)


func _on_punch_left_timeout() -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if not still punching left
	if not is_punching_left: return

	# Apply impact at bone position if colliding
	if ray_cast_middle.is_colliding():
		var collider = ray_cast_middle.get_collider()
		apply_impact(collider, bone_name_left_hand, 1.0)

		# Player Punching Left -> Enemy Reacting Right
		if collider is CharacterBody3D \
		or collider is RigidBody3D \
		or collider is SoftBody3D:
			if collider.has_method("animate_hit_high_right"):
				collider.rpc("animate_hit_high_right", self)


func _on_punch_right_timeout() -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if not still punching right
	if not is_punching_right: return

	# Apply impact at bone position if colliding
	if ray_cast_middle.is_colliding():
		var collider = ray_cast_middle.get_collider()
		apply_impact(collider, bone_name_right_hand, 1.0)

		# Player Punching Right -> Enemy Reacting Left
		if collider is CharacterBody3D \
		or collider is RigidBody3D \
		or collider is SoftBody3D:
			if collider.has_method("animate_hit_high_left"):
				collider.rpc("animate_hit_high_left", self)


func _on_enemy_detection_body_entered(body: Node3D) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	if body.is_in_group("Focusable"):
		targets[body.get_instance_id()] = body
		if body.get_node_or_null("FocusTargetIndicator") == null:
			var indicator_instance = focus_target_indicator.duplicate()
			body.add_child(indicator_instance)
			indicator_instance.show()


func _on_enemy_detection_body_exited(body: Node3D) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	if body.is_in_group("Focusable"):
		targets.erase(body.get_instance_id())
		# Reset material if this was the focused target
		if current_focused_target == body:
			_reset_target_material(body)
			current_focused_target = null
		# Queue free the indicator
		var indicator = body.get_node_or_null("FocusTargetIndicator")
		if indicator:
			indicator.queue_free()
