extends BaseState

const ANIMATION_JUMPING := "AnimationLibrary_Godot/Jump_Start"
const NODE_NAME := "Jumping"
const NODE_STATE := States.State.JUMPING


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "climbing"
	if event.is_action_pressed(player.controls.button_0):
		if player.enable_climbing:
			# Check if the player is facing a surface
			if player.ray_cast_high.is_colliding():
				# Get the collision object
				var collision_object = player.ray_cast_high.get_collider()
				# Check if the collision object is "climbable"
				if not collision_object is CharacterBody3D \
				and not collision_object is SoftBody3D:
					# Start "climbing"
					transition_state(player.current_state, States.State.CLIMBING)
					return

	# Ⓐ/[Space] _pressed_ -> Start "double-jumping"
	if event.is_action_pressed(player.controls.button_0):
		if player.enable_double_jumping \
		and not player.is_double_jumping:
			player.is_double_jumping = true
			# Increase the player's velocity in the up direction
			player.velocity += player.up_direction * player.speed_jumping
			return

	# Ⓐ/[Space] _pressed_ -> Start "flying"
	if event.is_action_pressed(player.controls.button_0):
		if player.enable_flying:
			# Start "flying"
			transition_state(player.current_state, States.State.FLYING)
			return

	# Ⓐ/[Space] _pressed_ -> Start "paragliding"
	if event.is_action_pressed(player.controls.button_0):
		if player.enable_paragliding:
			# Start "paragliding"
			transition_state(player.current_state, States.State.PARAGLIDING)
			return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if the player velocity in the up direction is not positive -> Start "falling"
	if player.velocity.dot(player.up_direction) <= 0.0:
		transition_state(NODE_STATE, States.State.FALLING)
		return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if in first person and moving backwards
	var play_backwards = (player.camera.perspective == player.camera.Perspective.FIRST_PERSON) and Input.is_action_pressed(player.controls.move_down)

	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_JUMPING:
		# Play the "jumping" animation
		if play_backwards:
			player.animation_player.play_backwards(ANIMATION_JUMPING)
		else:
			player.animation_player.play(ANIMATION_JUMPING)


## Start "jumping".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.JUMPING

	# Flag the player as "jumping"
	player.is_jumping = true

	# Increase the player's velocity in the up direction
	player.velocity += player.up_direction * player.speed_jumping


## Stop "jumping".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "jumping"
	player.is_jumping = false
