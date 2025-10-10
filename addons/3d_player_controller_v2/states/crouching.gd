extends BaseState

const ANIMATION_CROUCHING := "AnimationLibrary_Godot/Crouch_Idle"
const NODE_NAME := "Crouching"
const NODE_STATE := States.State.CROUCHING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Ⓨ/[Ctrl] _just_released_ -> Start "standing"
	if Input.is_action_just_released(player.controls.button_3):
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Check if the player is moving -> Start "crawling"
	if player.input_direction != Vector2.ZERO:
		transition_state(NODE_STATE, States.State.CRAWLING)
		return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_CROUCHING:
		# Play the "crouching" animation
		player.animation_player.play(ANIMATION_CROUCHING)


## Start "crouching".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.CROUCHING

	# Flag the player as "crouching"
	player.is_crouching = true

	# Set the player's speed
	player.speed_current = 0.0


## Stop "crouching".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "crouching"
	player.is_crouching = false
