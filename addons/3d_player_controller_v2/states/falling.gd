extends BaseState

const ANIMATION_FALLING := "AnimationLibrary_Godot/Jump"
const NODE_NAME := "Falling"
const NODE_STATE := States.State.FALLING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if the player is on a floor -> Start "standing"
	if player.is_on_floor():
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if in first person and moving backwards
	var play_backwards = (player.camera.perspective == player.camera.Perspective.FIRST_PERSON) and Input.is_action_pressed(player.controls.move_down)

	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_FALLING:
		# Play the "falling" animation
		if play_backwards:
			player.animation_player.play_backwards(ANIMATION_FALLING)
		else:
			player.animation_player.play(ANIMATION_FALLING)


## Start "falling".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.FALLING

	# Flag the player as "falling"
	player.is_falling = true


## Stop "falling".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "falling"
	player.is_falling = false
