extends BaseState

const ANIMATION_CLIMBING_IDLE := "AnimationLibrary_Godot/Climb_Idle"
const ANIMATION_CLIMBING_UP := "AnimationLibrary_Godot/Climb_Up"
const ANIMATION_CLIMBING_DOWN := "AnimationLibrary_Godot/Climb_Down"
const ANIMATION_CLIMBING_LEFT := "AnimationLibrary_Godot/Climb_Left"
const ANIMATION_CLIMBING_RIGHT := "AnimationLibrary_Godot/Climb_Right"
const NODE_STATE := States.State.CLIMBING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the player's hang is braced (the collider has somewhere for the player's footing)
	var is_braced = player.ray_cast_low.is_colliding()
	# Check if the player is shimmying
	var is_shimmying = Input.is_action_pressed(player.controls.move_left) or Input.is_action_pressed(player.controls.move_right)

	# Check if the animation player is not already playing the appropriate animation
	if Input.is_action_pressed(player.controls.move_up) \
	and player.animation_player.current_animation != ANIMATION_CLIMBING_UP:
		# Play the "climbing" animation
		player.animation_player.current_animation = ANIMATION_CLIMBING_UP

	# Check if the animation player is not already playing the appropriate animation
	if Input.is_action_pressed(player.controls.move_down) \
	and player.animation_player.current_animation != ANIMATION_CLIMBING_DOWN:
		# Play the "climbing" animation
		player.animation_player.current_animation = ANIMATION_CLIMBING_DOWN

	# Check if the animation player is not already playing the appropriate animation
	if Input.is_action_pressed(player.controls.move_left) \
	and player.animation_player.current_animation != ANIMATION_CLIMBING_LEFT:
		# Play the "climbing" animation
		player.animation_player.current_animation = ANIMATION_CLIMBING_LEFT

	# Check if the animation player is not already playing the appropriate animation
	if Input.is_action_pressed(player.controls.move_right) \
	and player.animation_player.current_animation != ANIMATION_CLIMBING_RIGHT:
		# Play the "climbing" animation
		player.animation_player.current_animation = ANIMATION_CLIMBING_RIGHT

	# Get if not moving
	if Input.get_vector(player.controls.move_left, player.controls.move_right, player.controls.move_up, player.controls.move_down) == Vector2.ZERO:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_CLIMBING_IDLE:
			# Play the "climbing" animation
			player.animation_player.current_animation = ANIMATION_CLIMBING_IDLE


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

	# Get the player's height
	var player_height = player.get_node("CollisionShape3D").shape.height

	# Get the player's width
	var player_width = player.get_node("CollisionShape3D").shape.radius * 2

	# Get the collision point
	var collision_point = player.ray_cast_high.get_collision_point()

	# [DEBUG] Draw a debug sphere at the collision point
	player.debug.draw_debug_sphere(collision_point, Color.RED)

	# Get the collision normal
	var collision_normal = player.ray_cast_high.get_collision_normal()

	# Calculate the wall direction
	var wall_direction = -collision_normal

	# Calculate the direction from the player to collision point
	var direction = (collision_point - player.position).normalized()

	# Calculate new point by moving back from point along the direction by the given player radius
	collision_point = collision_point - direction * player_width

	# [DEBUG] Draw a debug sphere at the collision point
	player.debug.draw_debug_sphere(collision_point, Color.YELLOW)

	# Adjust the point relative to the player's height
	collision_point = Vector3(collision_point.x, player.position.y, collision_point.z)

	# Move the player to the collision point
	player.global_position = collision_point

	# [DEBUG] Draw a debug sphere at the collision point
	player.debug.draw_debug_sphere(collision_point, Color.GREEN)

	# Make the player face the wall while keeping upright
	if player.position != player.position + wall_direction:
		player.visuals.look_at(player.position + wall_direction, player.up_direction)


## Stop "climbing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "climbing"
	player.is_climbing = false
