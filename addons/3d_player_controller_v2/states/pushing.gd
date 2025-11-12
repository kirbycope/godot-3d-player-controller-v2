extends BaseState

const ANIMATION_PUSHING := "Standing_Pushing/mixamo_com"
const NODE_NAME := "Pushing"
const NODE_STATE := States.State.PUSHING


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if the player has stopped pushing -> Transition to "standing" state
	if player.input_direction == Vector2.ZERO \
	or (not player.ray_cast_middle.is_colliding() and not player.ray_cast_high.is_colliding()):
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_PUSHING:
		# Play the "pushing" animation
		player.animation_player.play(ANIMATION_PUSHING)


## Start "pushing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Flag the player as "pushing"
	player.is_pushing = true


## Stop "pushing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "pushing"
	player.is_pushing = false
