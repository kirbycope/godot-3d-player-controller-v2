extends BaseState

const ANIMATION_THROWING := "Standing_Throw/mixamo_com"
const NODE_NAME := "Throwing"
const NODE_STATE := States.State.THROWING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	if player.animation_player.current_animation != ANIMATION_THROWING:
		player.animation_player.play(ANIMATION_THROWING)
		player.animation_player.connect("animation_finished", _on_animation_finished)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == ANIMATION_THROWING:
		player.animation_player.disconnect("animation_finished", _on_animation_finished)
		transition_state(NODE_STATE, player.previous_state)


## Start "throwing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.THROWING

	# Flag the player as "throwing"
	player.is_throwing = true


## Stop "throwing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "throwing"
	player.is_throwing = false
