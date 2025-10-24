extends BaseState

const ANIMATION_PUNCHING_RIGHT := "AnimationLibrary_Godot/Punch_Cross"
const NODE_NAME := "Punching_Right"
#const NODE_STATE := States.State.PUNCHING_RIGHT


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
	if player.animation_player.current_animation != ANIMATION_PUNCHING_RIGHT:
		# Play the "punching" animation
		player.animation_player.play(ANIMATION_PUNCHING_RIGHT)
		# Set a callback for when the animation finishes
		player.animation_player.connect("animation_finished", _on_animation_finished)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == ANIMATION_PUNCHING_RIGHT:
		# Disconnect the signal to avoid multiple connections
		player.animation_player.disconnect("animation_finished", _on_animation_finished)
		# Transition back to the idle state
		#transition_state(NODE_STATE, States.State.STANDING)


## Start "punching right".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	#player.current_state = States.State.PUNCHING_RIGHT

	# Flag the player as "punching right"
	player.is_punching_right = true


## Stop "punching right".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "punching right"
	player.is_punching_right = false
