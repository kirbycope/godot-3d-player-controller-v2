extends BaseState
class_name Reacting
## 🤕 Reacting to hits (low/high, left/right).

# Reacting 🔵 Mixamo animations
const MIX_ANIMATION_REACTING_LOW_LEFT := "Standing_Reaction_Low_Left/mixamo_com"
const MIX_ANIMATION_REACTING_LOW_RIGHT := "Standing_Reaction_Low_Right/mixamo_com"
const MIX_ANIMATION_REACTING_HIGH_LEFT := "Standing_Reaction_High_Left/mixamo_com"
const MIX_ANIMATION_REACTING_HIGH_RIGHT := "Standing_Reaction_High_Right/mixamo_com"
const MIX_ANIMATION_REACTING_KNOCKED_OVER := "Standing_Falling_Down/mixamo_com"
const MIX_ANIMATION_REACTING_GETTING_UP := "Standing_Getting_Up/mixamo_com"

const NODE_STATE := States.State.REACTING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	var mixamo_animation := ""
	if player.is_reacting_low_left:
		mixamo_animation = MIX_ANIMATION_REACTING_LOW_LEFT
	elif player.is_reacting_low_right:
		mixamo_animation = MIX_ANIMATION_REACTING_LOW_RIGHT
	elif player.is_reacting_high_left:
		mixamo_animation = MIX_ANIMATION_REACTING_HIGH_LEFT
	elif player.is_reacting_high_right:
		mixamo_animation = MIX_ANIMATION_REACTING_HIGH_RIGHT
	elif player.is_reacting_knocked_over:
		mixamo_animation = MIX_ANIMATION_REACTING_KNOCKED_OVER
	else:
		return

	var animation = mixamo_animation
	var current_animation = player.animation_player_current_animation()
	if current_animation != animation:
		player.animation_player_play(animation)
		player.animation_player_connect("animation_finished", _on_animation_finished)


func _on_animation_finished(animation_name: String) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	if animation_name == MIX_ANIMATION_REACTING_LOW_LEFT:
		player.is_reacting_left = false
	elif animation_name == MIX_ANIMATION_REACTING_LOW_RIGHT:
		player.is_reacting_right = false
	elif animation_name == MIX_ANIMATION_REACTING_HIGH_LEFT:
		player.is_reacting_left = false
	elif animation_name == MIX_ANIMATION_REACTING_HIGH_RIGHT:
		player.is_reacting_right = false
	transition_state(NODE_STATE, player.previous_state)


## Start "reacting".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.REACTING

	# Flag the player as "reacting"
	player.is_reacting = true

	# Connect animation finished signal
	player.animation_player_connect("animation_finished", _on_animation_finished)


## Stop "reacting".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "reacting"
	player.is_reacting = false

	# Clear state specific flags
	_on_animation_finished(player.animation_player_current_animation()) 

	# Disconnect animation finished signal
	if player.animation_player_is_connected("animation_finished", _on_animation_finished):
		player.animation_player_disconnect("animation_finished", _on_animation_finished)
