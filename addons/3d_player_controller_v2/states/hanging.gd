extends BaseState

const ANIMATION_HANGING := "Hanging_Idle/mixamo_com"
const ANIMATION_HANGING_SHIMMY_LEFT := "Hanging_Shimmy_Left_In_Place/mixamo_com"
const ANIMATION_HANGING_SHIMMY_RIGHT := "Hanging_Shimmy_Right_In_Place/mixamo_com"
const ANIMATION_HANGING_BRACED := "Hanging_Braced_Idle/mixamo_com"
const ANIMATION_HANGING_BRACED_SHIMMY_LEFT := "Hanging_Braced_Shimmy_Left_In_Place/mixamo_com"
const ANIMATION_HANGING_BRACED_SHIMMY_RIGHT := "Hanging_Braced_Shimmy_Right_In_Place/mixamo_com"
const NODE_NAME := "Hanging"
const NODE_STATE := States.State.HANGING


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


## Stop "hanging".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "hanging"
	player.is_hanging = false
