extends BaseState
class_name Flipping
## 🤸 Flipping through the air (forward or backward).

# Flipping 🔵 Mixamo animations
const MIX_ANIMATION_FLIPPING_BACKWARD := "Running_Backward_Flip/mixamo_com"
const MIX_ANIMATION_FLIPPING_FORWARD := "Running_Forward_Flip/mixamo_com"

const NODE_STATE := States.State.FLIPPING

var flip_direction := Vector2.ZERO ## The direction of the flip (backward = positive y, forward = negative y)


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Check if the player is on a floor
	if player.is_on_floor():
		# Fell too fast -> Start "ragdolling"
		if player.virtual_velocity.y < -player.gravity and player.enable_ragdolling:
			transition_state(NODE_STATE, States.State.RAGDOLLING)
			return
		# Fell safely -> Start "standing"
		else:
			transition_state(NODE_STATE, States.State.STANDING)
			return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on flip direction.
func play_animation() -> void:
	var current_animation = player.animation_player_current_animation()
	var target_animation: String

	# Determine which animation to play based on flip direction
	if flip_direction.y > 0:  # Backward flip
		# Adjust the animation playback speed (the animation is too long)
		player.animation_player_set_speed_scale(1.5)
		target_animation = MIX_ANIMATION_FLIPPING_BACKWARD
	else:  # Forward flip
		# [Re]set the animation playback speed
		player.animation_player_set_speed_scale(1.0)
		target_animation = MIX_ANIMATION_FLIPPING_FORWARD
	
	if current_animation != target_animation:
		# Start the animation 0.2 seconds in (to skip the initial crouch)
		player.animation_player_play_section(target_animation, 0.2)


## Called when the flip animation finishes.
func _on_animation_finished(animation_name: String) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# [Re]set the animation playback speed
	player.animation_player_set_speed_scale(1.0)

	# Flag the player as not "flipping"
	player.is_flipping = false


## Start "flipping".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.FLIPPING

	# Flag the player as "flipping"
	player.is_flipping = true

	# Set the flip direction based on the input
	if Input.is_action_pressed(Controls.MOVE_DOWN):
		flip_direction = Vector2(0, 1)
		# Increase the player's velocity in the flip direction (Backward)
		var dir = player.transform.basis * Vector3(0, 0, 1)
		player.velocity += dir * player.speed_jumping * 0.75
	else:
		flip_direction = Vector2(0, -1)
		# Increase the player's velocity in the flip direction (Forward)
		var dir = player.transform.basis * Vector3(0, 0, -1)
		player.velocity += dir * player.speed_jumping * 0.75

	# Increase the player's velocity in the up direction
	player.velocity += player.up_direction * player.speed_jumping

	# Connect animation finished signal
	player.animation_player_connect("animation_finished", _on_animation_finished)
	
	# Play the animation
	play_animation()


## Stop "flipping".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "flipping"
	player.is_flipping = false

	# Reset animation playback speed
	player.animation_player_set_speed_scale(1.0)

	# Disconnect animation finished signal
	player.animation_player_disconnect("animation_finished", _on_animation_finished)
