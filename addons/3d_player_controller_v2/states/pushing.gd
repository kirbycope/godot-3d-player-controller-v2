extends BaseState
class_name Pushing
## 🧱 Pushing a large object or against the wall.

# Pushing 🔵 Mixamo animations
const MIX_ANIMATION_PUSHING := "Standing_Pushing/mixamo_com"
# Pushing 🟣 Quaternius animations
const QUAT_ANIMATION_PUSHING := "UAL1/Push"
const QUAT_ANIMATION_PUSHING_START := "UAL1/Push_Enter"
const QUAT_ANIMATION_PUSHING_STOP := "UAL1/Push_Exit"

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
	var anim = QUAT_ANIMATION_PUSHING if player.animation_set == 1 else MIX_ANIMATION_PUSHING
	if player.animation_player_current_animation() != anim:
		# Play the "pushing" animation
		player.animation_player_play(anim)
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
