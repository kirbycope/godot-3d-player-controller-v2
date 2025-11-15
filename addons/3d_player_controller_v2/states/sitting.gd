extends BaseState

## Handles sitting state with idle animation and transition to standing on jump button press.

const ANIMATION_SITTING := "Sitting/mixamo_com"
const NODE_NAME := "Sitting"
const NODE_STATE := States.State.SITTING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "standing"
	if event.is_action_pressed(player.controls.button_0) \
	and not player.chat.line_edit.visible:
		transition_state(NODE_STATE, States.State.STANDING)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_SITTING:
		player.animation_player.play(ANIMATION_SITTING)


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
