extends BaseState

const ANIMATION_ROLLING := "Rolling/mixamo_com"
const NODE_NAME := "Rolling"
const NODE_STATE := States.State.ROLLING


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# ToDo: Boost/roll longer if  Ⓐ/[Space] is pressed


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	if player.animation_player.current_animation != ANIMATION_ROLLING:
		_on_animation_finished(player.animation_player.current_animation)
		player.animation_player.play(ANIMATION_ROLLING)


func _on_animation_finished(animation_name: String) -> void:
	if animation_name == ANIMATION_ROLLING:
		if Input.is_action_pressed(player.controls.button_3):
			transition_state(NODE_STATE, States.State.CROUCHING)
		else:
			transition_state(NODE_STATE, States.State.STANDING)


## Start "rolling".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.ROLLING

	# Flag the player as "rolling"
	player.is_rolling = true

	# Set the player's speed
	player.speed_current = player.speed_rolling

	# Set the player collision shape's height
	player.collision_shape.shape.height = player.collision_height / 2

	# Set the player collision shape's position
	player.collision_shape.position = player.collision_position / 2

	# Connect animation finished signal
	player.animation_player.connect("animation_finished", _on_animation_finished)


## Stop "rolling".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "rolling"
	player.is_rolling = false

	# [Re]set the player collision shape's height
	player.collision_shape.shape.height = player.collision_height
	
	# [Re]set the player collision shape's position
	player.collision_shape.position = player.collision_position

	# Clear state specific flags
	_on_animation_finished(player.animation_player.current_animation)

	# Disconnect animation finished signal
	if player.animation_player.is_connected("animation_finished", _on_animation_finished):
		player.animation_player.disconnect("animation_finished", _on_animation_finished)
