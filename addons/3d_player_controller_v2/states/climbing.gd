extends BaseState

const ANIMATION_CLIMBING_IDLE := "AnimationLibrary_Godot/Climb_Idle"
const ANIMATION_CLIMBING_UP := "AnimationLibrary_Godot/Climb_Up"
const ANIMATION_CLIMBING_DOWN := "AnimationLibrary_Godot/Climb_Down"
const ANIMATION_CLIMBING_LEFT := "AnimationLibrary_Godot/Climb_Left"
const ANIMATION_CLIMBING_RIGHT := "AnimationLibrary_Godot/Climb_Right"
const NODE_NAME := "Climbing"
const NODE_STATE := States.State.CLIMBING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if the player has no raycast collision -> Start "falling"
	if not player.ray_cast_top.is_colliding() \
	and not player.ray_cast_high.is_colliding():
		# Start falling
		transition_state(NODE_STATE, States.State.FALLING)
		return

	# Check if the player is on the ground -> Start "standing"
	if player.is_on_floor() \
	and abs(player.velocity).length() < 0.2:
		# Start "standing"
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Check the eyeline for a ledge to grab -> Start "hanging"
	if not player.ray_cast_top.is_colliding() \
	and player.ray_cast_high.is_colliding():
		# Get the collision object
		var collision_object = player.ray_cast_high.get_collider()
		# Check if the collision object is "hangable"
		if not collision_object is CharacterBody3D \
		and not collision_object is SoftBody3D:
			# Start "hanging"
			transition_state(NODE_STATE, States.State.HANGING)
			return
	
	# # Ⓑ/[shift] _pressed_ -> Move faster while "climbing"
	if player.enable_sprinting:
		if Input.is_action_pressed(player.controls.button_1):
			player.speed_current = player.speed_climbing * 2
		else:
			player.speed_current = player.speed_climbing

	# Ⓨ/[Ctrl] _pressed_ -> Start "falling"
	if Input.is_action_just_pressed(player.controls.button_3):
		transition_state(NODE_STATE, States.State.FALLING)
		return

	# Move the player while climbing
	move_player()

	# Play the animation
	play_animation()


func move_player() -> void:
	# Get the collision normal (wall outward direction)
	var collision_normal_normalized: Vector3 = player.ray_cast_high.get_collision_normal().normalized()

	# Build an orthonormal basis for the wall plane using player's up and wall normal
	# Remove any component of up along the normal to get the wall-up (shimmy) axis
	var wall_up: Vector3 = (player.up_direction - collision_normal_normalized * player.up_direction.dot(collision_normal_normalized)).normalized()
	# Right axis along the wall (perpendicular to wall_up and normal)
	var wall_right: Vector3 = wall_up.cross(collision_normal_normalized).normalized()

	# Gather inputs mapped onto wall axies
	var move_direction: Vector3 = Vector3.ZERO
	if Input.is_action_pressed(player.controls.move_left):
		move_direction -= wall_right
	if Input.is_action_pressed(player.controls.move_right):
		move_direction += wall_right
	if Input.is_action_pressed(player.controls.move_up):
		move_direction += wall_up
	if Input.is_action_pressed(player.controls.move_down):
		move_direction -= wall_up

	# Normalize to keep diagonal speed consistent
	if move_direction.length() > 0.0:
		move_direction = move_direction.normalized()

	# Constrain velocity strictly to the wall plane, no motion into or away from the wall
	player.velocity = move_direction * player.speed_current

	# Ensure the visuals face the wall (optional subtle alignment)
	var wall_forward = -collision_normal_normalized
	if player.position != player.position + wall_forward:
		player.visuals.look_at(player.position + wall_forward, player.up_direction)


## Snaps the player to the wall they are climbing.
func move_to_wall() -> void:
	# Get the player's height
	var player_height = player.get_node("CollisionShape3D").shape.height

	# Get the player's width
	var player_width = player.get_node("CollisionShape3D").shape.radius * 1.5

	# Get the collision point
	var collision_point = player.ray_cast_high.get_collision_point()

	# [DEBUG] Draw a debug sphere at the collision point
	#player.debug.draw_debug_sphere(collision_point, Color.RED)

	# Calculate the direction from the player to collision point
	var direction = (collision_point - player.position).normalized()

	# Calculate new point by moving back from point along the direction by the given player radius
	collision_point = collision_point - direction * player_width

	# [DEBUG] Draw a debug sphere at the adjusted collision point
	#player.debug.draw_debug_sphere(collision_point, Color.YELLOW)

	# Adjust the point relative to the player's height
	collision_point = Vector3(collision_point.x, player.position.y, collision_point.z)

	# Move the player to the collision point
	player.global_position = collision_point

	# [DEBUG] Draw a debug sphere at the collision point
	#player.debug.draw_debug_sphere(collision_point, Color.GREEN)

	# Get the collision normal
	var collision_normal = player.ray_cast_high.get_collision_normal()

	# Calculate the wall direction
	var wall_direction = -collision_normal

	# Make the player face the wall while keeping upright
	if player.position != player.position + wall_direction:
		player.visuals.look_at(player.position + wall_direction, player.up_direction)


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Adjust playback speed based on climbing speed
	if player.speed_current > player.speed_climbing:
		player.animation_player.speed_scale = 1.5
	else:
		player.animation_player.speed_scale = 1.0

	# Determine intended direction once and prefer vertical over horizontal when both are pressed
	var input_vector: Vector2 = Input.get_vector(
		player.controls.move_left,
		player.controls.move_right,
		player.controls.move_up,
		player.controls.move_down
	)

	# Store the current animation as the target animation
	var target_animation: String = player.animation_player.current_animation

	# Idle when no input
	if input_vector == Vector2.ZERO:
		target_animation = ANIMATION_CLIMBING_IDLE
	else:
		# Prefer vertical movement for animation selection
		if abs(input_vector.y) > 0.0:
			if input_vector.y < 0.0:
				target_animation = ANIMATION_CLIMBING_UP
			else:
				target_animation = ANIMATION_CLIMBING_DOWN
		# Fall back to horizontal shimmy when no vertical input
		elif abs(input_vector.x) > 0.0:
			if input_vector.x < 0.0:
				target_animation = ANIMATION_CLIMBING_LEFT
			else:
				target_animation = ANIMATION_CLIMBING_RIGHT

	# Apply animation change only if needed to avoid rapid toggling
	if player.animation_player.current_animation != target_animation:
		player.animation_player.current_animation = target_animation


## Start "climbing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.CLIMBING

	# Flag the player as "climbing"
	player.is_climbing = true

	# Set the player's speed
	player.speed_current = player.speed_climbing

	# Reset velocity and virtual velocity
	player.velocity = Vector3.ZERO
	player.virtual_velocity = Vector3.ZERO

	# Move the player to the wall
	move_to_wall()


## Stop "climbing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "climbing"
	player.is_climbing = false

	# Reset animation playback speed
	player.animation_player.speed_scale = 1.0
