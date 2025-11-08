extends BaseState

const ANIMATION_CLIMBING_UP := "Climbing_Up/mixamo_com"
const ANIMATION_CLIMBING_DOWN := "Climbing_Down/mixamo_com"
const ANIMATION_CLIMBING_LEFT := "Hanging_Braced_Shimmy_Left/mixamo_com"
const ANIMATION_CLIMBING_RIGHT := "Hanging_Braced_Shimmy_Right/mixamo_com"
const NODE_NAME := "Climbing"
const NODE_STATE := States.State.CLIMBING


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓑ/[shift] _pressed_ -> Move faster while "climbing"
	if player.enable_sprinting:
		if event.is_action_pressed(player.controls.button_1):
			player.speed_current = player.speed_climbing * 2
		elif event.is_action_released(player.controls.button_1):
			player.speed_current = player.speed_climbing

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
		transition_state(NODE_STATE, States.State.FALLING)
		return

	# Check the eyeline for a ledge to grab -> Start "hanging"
	if player.enable_hanging:
		if not player.ray_cast_top.is_colliding() \
		and player.ray_cast_high.is_colliding():
			var collision_object = player.ray_cast_high.get_collider()
			if not collision_object is CharacterBody3D \
			and not collision_object is SoftBody3D:
				transition_state(NODE_STATE, States.State.HANGING)
				return

	# Move the player while climbing
	player.move_player()

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	if player.speed_current > player.speed_climbing:
		player.animation_player.speed_scale = 1.5
	else:
		player.animation_player.speed_scale = 1.0
	if player.input_direction.x < 0:
		if player.animation_player.current_animation != ANIMATION_CLIMBING_LEFT:
			player.animation_player.play(ANIMATION_CLIMBING_LEFT)
	elif player.input_direction.x > 0:
		if player.animation_player.current_animation != ANIMATION_CLIMBING_RIGHT:
			player.animation_player.play(ANIMATION_CLIMBING_RIGHT)
	else:
		if player.input_direction.y < 0:
			if player.animation_player.current_animation != ANIMATION_CLIMBING_UP:
				player.animation_player.play(ANIMATION_CLIMBING_UP)
		elif player.input_direction.y > 0:
			if player.animation_player.current_animation != ANIMATION_CLIMBING_DOWN:
				player.animation_player.play(ANIMATION_CLIMBING_DOWN)
		else:
			player.animation_player.pause()


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
	player.move_to_wall()

	# Play the appropriate animation
	await get_tree().process_frame
	player.play_locked_animation(ANIMATION_CLIMBING_UP, 0.2)


## Stop "climbing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "climbing"
	player.is_climbing = false

	# Reset animation playback speed
	player.animation_player.speed_scale = 1.0
