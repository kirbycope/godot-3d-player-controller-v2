extends BaseState

## Handles sliding state with collision shape adjustment, plays slide animation, and transitions to sprint/run/stand on completion.

const ANIMATION_SLIDING := "Running_Slide/mixamo_com"
const NODE_NAME := "Sliding"
const NODE_STATE := States.State.SLIDING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	if player.animation_player.current_animation != ANIMATION_SLIDING:
		_on_animation_finished(player.animation_player.current_animation)
		player.animation_player.play(ANIMATION_SLIDING)


func _on_animation_finished(animation_name: String) -> void:
	if animation_name == ANIMATION_SLIDING:
		if Input.is_action_pressed(player.controls.button_1):
			transition_state(NODE_STATE, States.State.SPRINTING)
		elif player.input_direction != Vector2.ZERO:
			transition_state(NODE_STATE, States.State.RUNNING)
		else:
			transition_state(NODE_STATE, States.State.STANDING)


## Start "sliding".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.SLIDING

	# Flag the player as "sliding"
	player.is_sliding = true

	# Set the player collision shape's height
	player.collision_shape.shape.height = player.collision_height / 2

	# Set the player collision shape's position
	player.collision_shape.position = player.collision_position / 2

	# Connect animation finished signal
	player.animation_player.connect("animation_finished", _on_animation_finished)


## Stop "sliding".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "sliding"
	player.is_sliding = false

	# [Re]set the player collision shape's height
	player.collision_shape.shape.height = player.collision_height

	# [Re]set the player collision shape's position
	player.collision_shape.position = player.collision_position

	# Clear state specific flags
	_on_animation_finished(player.animation_player.current_animation)

	# Disconnect animation finished signal
	if player.animation_player.is_connected("animation_finished", _on_animation_finished):
		player.animation_player.disconnect("animation_finished", _on_animation_finished)
