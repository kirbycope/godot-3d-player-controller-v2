extends BaseState
class_name Pushing
## 🧱 Pushing a large object or against the wall.

# Pushing 🔵 Mixamo animations
const MIX_ANIMATION_PUSHING := "Standing_Pushing/mixamo_com"

const NODE_STATE := States.State.PUSHING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Check if the player has stopped pushing -> Transition to "standing" state
	if player.input_direction == Vector2.ZERO or (not player.ray_cast_middle.is_colliding() and not player.ray_cast_high.is_colliding()):
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	var animation = MIX_ANIMATION_PUSHING
	var current_animation = player.animation_player_current_animation()
	if current_animation != animation:
		# Play the "pushing" animation
		player.animation_player_play(animation)
	# Pause the animation if no input
	if player.input_direction == Vector2.ZERO:
		player.animation_player_pause()


## Start "pushing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.PUSHING

	# Flag the player as "pushing"
	player.is_pushing = true


## Stop "pushing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "pushing"
	player.is_pushing = false
