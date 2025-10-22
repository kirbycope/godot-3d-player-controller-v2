extends BaseState

const ANIMATION_SLIDING := "Running_Slide/mixamo_com"
const NODE_NAME := "Sliding"
const NODE_STATE := States.State.SLIDING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_SLIDING:
		# Play the "sliding" animation
		player.animation_player.play(ANIMATION_SLIDING)
		# Set a callback for when the animation finishes
		player.animation_player.connect("animation_finished", _on_animation_finished)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == ANIMATION_SLIDING:
		# Disconnect the signal to avoid multiple connections
		player.animation_player.disconnect("animation_finished", _on_animation_finished)
		if Input.is_action_pressed(player.controls.button_1):
			# Transition to the "sprinting" state
			transition_state(NODE_STATE, States.State.SPRINTING)
		else:
			# Transition back to the idle state
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
	player.collision_shape_3d.shape.height = player.collision_height / 2

	# Set the player collision shape's position
	player.collision_shape_3d.position = player.collision_position / 2


## Stop "sliding".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "sliding"
	player.is_sliding = false

	# [Re]set the player collision shape's height
	player.collision_shape_3d.shape.height = player.collision_height

	# [Re]set the player collision shape's position
	player.collision_shape_3d.position = player.collision_position
