extends BaseState

const ANIMATION_SKATEBOARDING := "Skateboarding_In_Place/mixamo_com"
const NODE_NAME := "Skateboarding"
const NODE_STATE := States.State.SKATEBOARDING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_SKATEBOARDING:
		player.animation_player.play(ANIMATION_SKATEBOARDING)


## Start "skateboarding".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.SKATEBOARDING

	# Flag the player as "skateboarding"
	player.is_skateboarding = true

	# Set the player's speed
	player.speed_current = player.speed_skateboarding


## Stop "skateboarding".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "skateboarding"
	player.is_skateboarding = false
