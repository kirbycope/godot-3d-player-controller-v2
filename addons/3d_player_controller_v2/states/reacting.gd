extends BaseState

const ANIMATION_REACTING_LOW_LEFT := "Standing_Reaction_Low_Left" + "/mixamo_com"
const ANIMATION_REACTING_LOW_RIGHT := "Standing_Reaction_Low_Right" + "/mixamo_com"
const ANIMATION_REACTING_HIGH_LEFT := "Standing_Reaction_High_Left" + "/mixamo_com"
const ANIMATION_REACTING_HIGH_RIGHT := "Standing_Reaction_High_Right" + "/mixamo_com"
const NODE_NAME := "Reacting"
const NODE_STATE := States.State.REACTING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	if player.is_reacting_low_left:
		if player.animation_player.current_animation != ANIMATION_REACTING_LOW_LEFT:
			player.animation_player.play(ANIMATION_REACTING_LOW_LEFT)
			player.animation_player.connect("animation_finished", _on_animation_finished)
	elif player.is_reacting_low_right:
		if player.animation_player.current_animation != ANIMATION_REACTING_LOW_RIGHT:
			player.animation_player.play(ANIMATION_REACTING_LOW_RIGHT)
			player.animation_player.connect("animation_finished", _on_animation_finished)
	elif player.is_reacting_high_left:
		if player.animation_player.current_animation != ANIMATION_REACTING_HIGH_LEFT:
			player.animation_player.play(ANIMATION_REACTING_HIGH_LEFT)
			player.animation_player.connect("animation_finished", _on_animation_finished)
	elif player.is_reacting_high_right:
		if player.animation_player.current_animation != ANIMATION_REACTING_HIGH_RIGHT:
			player.animation_player.play(ANIMATION_REACTING_HIGH_RIGHT)
			player.animation_player.connect("animation_finished", _on_animation_finished)


func _on_animation_finished(anim_name: String) -> void:
	player.animation_player.disconnect("animation_finished", _on_animation_finished)
	if anim_name == ANIMATION_REACTING_LOW_LEFT:
		player.is_reacting_left = false
	elif anim_name == ANIMATION_REACTING_LOW_RIGHT:
		player.is_reacting_right = false
	elif anim_name == ANIMATION_REACTING_HIGH_LEFT:
		player.is_reacting_left = false
	elif anim_name == ANIMATION_REACTING_HIGH_RIGHT:
		player.is_reacting_right = false
	transition_state(NODE_STATE, player.previous_state)


## Start "reacting".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.SLIDING

	# Flag the player as "reacting"
	player.is_reacting = true


## Stop "reacting".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "reacting"
	player.is_reacting = false
