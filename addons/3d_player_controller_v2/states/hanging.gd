extends BaseState

const ANIMATION_HANGING := "Hanging_Idle/mixamo_com"
const ANIMATION_HANGING_SHIMMY_LEFT := "Hanging_Shimmy_Left_In_Place/mixamo_com"
const ANIMATION_HANGING_SHIMMY_RIGHT := "Hanging_Shimmy_Right_In_Place/mixamo_com"
const ANIMATION_HANGING_BRACED := "Hanging_Braced_Idle/mixamo_com"
const ANIMATION_HANGING_BRACED_SHIMMY_LEFT := "Hanging_Braced_Shimmy_Left_In_Place/mixamo_com"
const ANIMATION_HANGING_BRACED_SHIMMY_RIGHT := "Hanging_Braced_Shimmy_Right_In_Place/mixamo_com"
const NODE_NAME := "Hanging"
const NODE_STATE := States.State.HANGING


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "mantling"
	if event.is_action_pressed(player.controls.button_0):
		if player.ray_cast_jump_target.is_colliding():
			player.global_position = player.ray_cast_jump_target.get_collision_point()
			transition_state(NODE_STATE, States.State.STANDING) # TODO: Create a mantling state
			return

	# Ⓨ/[Ctrl] _pressed_ -> Start "falling"
	if event.is_action_pressed(player.controls.button_3):
		transition_state(NODE_STATE, States.State.FALLING)
		return


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

	# Ⓑ/[shift] _pressed_ -> Move faster while "hanging"
	if player.enable_sprinting:
		if Input.is_action_pressed(player.controls.button_1):
			player.speed_current = player.speed_hanging * 2
		else:
			player.speed_current = player.speed_hanging

	# Move the player while hanging
	move_player()

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Adjust playback speed based on hanging speed
	if player.speed_current > player.speed_hanging:
		player.animation_player.speed_scale = 1.5
	else:
		player.animation_player.speed_scale = 1.0

	# Check if the player's hang is braced (the collider has somewhere for the player's footing)
	var is_braced = player.ray_cast_low.is_colliding()

	# Move left
	if Input.is_action_pressed(player.controls.move_left):
		if is_braced:
			player.animation_player.play(ANIMATION_HANGING_BRACED_SHIMMY_LEFT)
		else:
			player.animation_player.play(ANIMATION_HANGING_SHIMMY_LEFT)

	# Move right
	elif Input.is_action_pressed(player.controls.move_right):
		if is_braced:
			player.animation_player.play(ANIMATION_HANGING_BRACED_SHIMMY_RIGHT)
		else:
			player.animation_player.play(ANIMATION_HANGING_SHIMMY_RIGHT)

	# Idle
	else:
		if is_braced:
			player.animation_player.play(ANIMATION_HANGING_BRACED)
		else:
			player.animation_player.play(ANIMATION_HANGING)


## Start "hanging".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.HANGING

	# Flag the player as "hanging"
	player.is_hanging = true

	# Set the player's speed
	player.speed_current = player.speed_hanging

	# Reset velocity and virtual velocity
	player.velocity = Vector3.ZERO
	player.virtual_velocity = Vector3.ZERO

	# Move the player to the wall
	move_to_wall()


## Stop "hanging".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "hanging"
	player.is_hanging = false

	# Reset animation playback speed
	player.animation_player.speed_scale = 1.0
