extends BaseState

const ANIMATION_STANDING := "AnimationLibrary_Godot/Idle"
const NODE_NAME := "Standing"
const NODE_STATE := States.State.STANDING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Ⓨ/[Ctrl] _pressed_ -> Start "crouching"
	if player.enable_crouching:
		if Input.is_action_pressed(player.controls.button_3) \
		and player.is_on_floor():
			transition_state(NODE_STATE, States.State.CROUCHING)
			return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_STANDING:
		# Play the "standing idle" animation
		player.animation_player.play(ANIMATION_STANDING)


## Start "standing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = States.State.STANDING
	# Flag the player as "standing"
	player.is_standing = true
	# Set the player's speed
	player.speed_current = 0.0
	# Set the player's velocity
	player.velocity = Vector3.ZERO


## Stop "standing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# Flag the player as not "standing"
	player.is_standing = false
