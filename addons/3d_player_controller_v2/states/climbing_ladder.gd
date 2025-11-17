extends BaseState

## Handles ladder climbing movement, animation speed scaling, and transitions off the ladder.

const ANIMATION_CLIMBING_LADDER := "Climbing_Ladder/mixamo_com"
const NODE_NAME := "ClimbingLadder"
const NODE_STATE := States.State.CLIMBING_LADDER


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓑ/[shift] _pressed_ -> Move faster while "climbing"
	if player.enable_sprinting:
		if event.is_action_pressed(player.controls.button_1):
			player.speed_current = player.speed_climbing * 2
		else:
			player.speed_current = player.speed_climbing

	# Ⓨ/[Ctrl] _pressed_ -> Start "falling"
	if event.is_action_pressed(player.controls.button_3):
		transition_state(NODE_STATE, States.State.FALLING)
		return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check the eyeline for a ledge to grab -> Move to "jump target" (like mantling)
	if not player.ray_cast_top.is_colliding() \
	and player.ray_cast_high.is_colliding():
		# Make sure there is somewhere for the player to "exit" climbing the ladder
		if player.ray_cast_jump_target.is_colliding():
			player.global_position = player.ray_cast_jump_target.global_position
			transition_state(NODE_STATE, States.State.STANDING)
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
	if player.animation_player.current_animation != ANIMATION_CLIMBING_LADDER:
		player.animation_player.play(ANIMATION_CLIMBING_LADDER, 0.0)
	if player.input_direction.y < 0:
		if player.animation_player.current_animation != ANIMATION_CLIMBING_LADDER:
			player.animation_player.play(ANIMATION_CLIMBING_LADDER)
	elif player.input_direction.y > 0:
		if player.animation_player.current_animation != ANIMATION_CLIMBING_LADDER:
			player.animation_player.play_backwards(ANIMATION_CLIMBING_LADDER)
	else:
		if player.animation_player.current_animation == ANIMATION_CLIMBING_LADDER:
			player.animation_player.play(ANIMATION_CLIMBING_LADDER, 0.0)
		player.animation_player.pause()


## Start "climbing ladder".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.CLIMBING_LADDER

	# Flag the player as "climbing ladder"
	player.is_climbing_ladder = true

	# Set the player's speed
	player.speed_current = player.speed_climbing

	# Reset velocity and virtual velocity
	player.velocity = Vector3.ZERO
	player.virtual_velocity = Vector3.ZERO

	# Move the player to the ladder
	player.move_to_ladder()

	# Play the appropriate animation
	await get_tree().process_frame
	player.play_locked_animation(ANIMATION_CLIMBING_LADDER, 0.2)


## Stop "climbing ladder".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "climbing ladder"
	player.is_climbing_ladder = false

	# Reset animation playback speed
	player.animation_player.speed_scale = 1.0
