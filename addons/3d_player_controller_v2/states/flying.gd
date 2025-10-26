extends BaseState

const ANIMATION_FLYING := "Flying/mixamo_com"
const ANIMATION_FLYING_FAST := "Flying_Fast/mixamo_com"
const NODE_NAME := "Flying"
const NODE_STATE := States.State.FLYING


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if the player is on the ground -> Start "standing"
	if player.is_on_floor() \
	and abs(player.velocity).length() < 0.2:
		# Start "standing"
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Ⓐ/[Space] button currently _pressed_
	if Input.is_action_pressed(player.controls.button_0):
		# Increase the player's vertical position
		player.position.y += 5 * delta

	# Ⓑ/[shift] _pressed_ -> Move faster while "flying"
	if player.enable_sprinting:
		if Input.is_action_pressed(player.controls.button_1):
			player.speed_current = player.speed_flying * 2
		else:
			player.speed_current = player.speed_flying

	# Ⓨ/[Ctrl] currently _pressed_
	if Input.is_action_pressed(player.controls.button_3):
		# Decrease the player's vertical position
		player.position.y -= 5 * delta

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	if player.speed_current == player.speed_flying * 2:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_FLYING_FAST:
			player.animation_player.play(ANIMATION_FLYING_FAST)
	else:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_FLYING:
			player.animation_player.play(ANIMATION_FLYING)


## Start "flying".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.FLYING

	# Flag the player as "flying"
	player.is_flying = true

	# Set the player's speed
	player.speed_current = player.speed_flying

	# Set player gravity to zero
	player.gravity = 0.0

	# Remove any existing vertical component of velocity so flying starts without upward/downward carryover
	# Vertical is defined along the player's current up_direction (supports local gravity / planets)
	var up: Vector3 = player.up_direction
	var vertical_speed: float = player.velocity.dot(up)
	player.velocity -= up * vertical_speed

	# Set the player collision shape's rotation
	player.collision_shape.rotation.x = deg_to_rad(90)

	# Set the player collision shape's position
	player.collision_shape.position = player.collision_position / 3


## Stop "flying".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "flying"
	player.is_flying = false

	# [Re]set player gravity to normal
	player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	
	# [Re]set the player collision shape's rotation
	player.collision_shape.rotation.x = deg_to_rad(0)

	# [Re]set the player collision shape's position
	player.collision_shape.position = player.collision_position
