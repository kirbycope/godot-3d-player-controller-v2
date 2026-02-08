extends BaseState
class_name Sitting
## 🪑 Sitting down (at chair height).

# Sitting 🔵 Mixamo animations
const MIX_ANIMATION_SITTING := "Sitting/mixamo_com"
# Sitting 🟣 Quaternius animations
const QUAT_ANIMATION_SITTING := "UAL1/Sitting_Idle"
#const QUAT_ANIMATION_SITTING_START := "UAL1/Sitting_Enter" # TODO: Implement
#const QUAT_ANIMATION_SITTING_STOP := "UAL1/Sitting_Exit" # TODO: Implement

const NODE_STATE := States.State.SITTING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "standing"
	if event.is_action_pressed(Controls.BUTTON_0) and not player.chat.line_edit.visible:
		transition_state(NODE_STATE, States.State.STANDING)
		return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	var animation = QUAT_ANIMATION_SITTING if player.animation_set == 1 else MIX_ANIMATION_SITTING
	var current_animation = player.animation_player_current_animation()
	if current_animation != animation:
		player.animation_player_play(animation)


## Start "sitting".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.SITTING

	# Flag the player as "sitting"
	player.is_sitting = true


## Stop "sitting".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "sitting"
	player.is_sitting = false
