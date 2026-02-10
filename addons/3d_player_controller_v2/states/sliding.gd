extends BaseState
class_name Sliding
## 🛷 Sliding on the floor.

# Sliding 🔵 Mixamo animations
const MIX_ANIMATION_SLIDING := "Running_Slide/mixamo_com"


const NODE_STATE := States.State.SLIDING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	var animation = MIX_ANIMATION_SLIDING
	var current_animation = player.animation_player_current_animation()
	if current_animation != animation:
		player.animation_player_play(animation)
		player.animation_player_connect("animation_finished", _on_animation_finished)

func _on_animation_finished(animation_name: String) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	if animation_name == MIX_ANIMATION_SLIDING:
		if player.animation_player_is_connected("animation_finished", _on_animation_finished):
			player.animation_player_disconnect("animation_finished", _on_animation_finished)
		if Input.is_action_pressed(Controls.BUTTON_1):
			transition_state(NODE_STATE, States.State.SPRINTING)
			return
		elif player.input_direction != Vector2.ZERO:
			transition_state(NODE_STATE, States.State.RUNNING)
			return
		else:
			transition_state(NODE_STATE, States.State.STANDING)
			return


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
	player.animation_player_connect("animation_finished", _on_animation_finished)


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
	_on_animation_finished(player.animation_player_current_animation()) 

	# Disconnect animation finished signal
	if player.animation_player_is_connected("animation_finished", _on_animation_finished):
		player.animation_player_disconnect("animation_finished", _on_animation_finished)
