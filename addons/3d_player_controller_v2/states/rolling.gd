extends BaseState

const ANIMATION_ROLLING := "Roll_In_Place/mixamo_com"
const NODE_NAME := "Rolling"
const NODE_STATE := States.State.ROLLING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_ROLLING:
		# Play the "rolling" animation
		player.animation_player.play(ANIMATION_ROLLING)
		# Set a callback for when the animation finishes
		player.animation_player.connect("animation_finished", _on_animation_finished)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == ANIMATION_ROLLING:
		# Disconnect the signal to avoid multiple connections
		player.animation_player.disconnect("animation_finished", _on_animation_finished)
		if Input.is_action_pressed(player.controls.button_3):
			# Transition to the "crouching" state
			transition_state(NODE_STATE, States.State.CROUCHING)
		else:
			# Transition back to the idle state
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
	player.collision_shape_3d.shape.height = player.collision_height / 2

	# Set the player collision shape's position
	player.collision_shape_3d.position = player.collision_position / 2


## Stop "rolling".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "rolling"
	player.is_rolling = false

	# [Re]set the player collision shape's height
	player.collision_shape_3d.shape.height = player.collision_height
	
	# [Re]set the player collision shape's position
	player.collision_shape_3d.position = player.collision_position
