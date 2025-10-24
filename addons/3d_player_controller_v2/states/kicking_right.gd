extends BaseState

const ANIMATION_KICKING_RIGHT := "AnimationLibrary_Godot/Kick"
const NODE_NAME := "Kicking_Right"
#const NODE_STATE := States.State.KICKING_RIGHT


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if the player is on the floor
	if player.is_on_floor():
		# Reset vertical velocity
		player.velocity = Vector3.ZERO

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_KICKING_RIGHT:
		# Play the "kicking" animation
		player.animation_player.play(ANIMATION_KICKING_RIGHT)
		# Set a callback for when the animation finishes
		player.animation_player.connect("animation_finished", _on_animation_finished)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == ANIMATION_KICKING_RIGHT:
		# Disconnect the signal to avoid multiple connections
		player.animation_player.disconnect("animation_finished", _on_animation_finished)
		# Transition back to the idle state
		#transition_state(NODE_STATE, States.State.STANDING)


## Start "kicking right".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	#player.current_state = States.State.KICKING_RIGHT

	# Flag the player as "kicking right"
	player.is_kicking_right = true


## Stop "kicking right".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "kicking right"
	player.is_kicking_right = false
