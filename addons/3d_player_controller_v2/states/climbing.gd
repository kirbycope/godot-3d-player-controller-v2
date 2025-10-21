extends BaseState

const ANIMATION_CLIMBING_IDLE := "AnimationLibrary_Godot/Climb_Idle"
const ANIMATION_CLIMBING_UP := "AnimationLibrary_Godot/Climb_Up"
const ANIMATION_CLIMBING_DOWN := "AnimationLibrary_Godot/Climb_Down"
const ANIMATION_CLIMBING_LEFT := "AnimationLibrary_Godot/Climb_Left"
const ANIMATION_CLIMBING_RIGHT := "AnimationLibrary_Godot/Climb_Right"
const NODE_NAME := "Climbing"
const NODE_STATE := States.State.CLIMBING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if the player has no raycast collision -> Start "falling"
	if not player.ray_cast_top.is_colliding() \
	and not player.ray_cast_high.is_colliding():
		# Start falling
		transition_state(NODE_STATE, States.State.FALLING)
		return

	# Check if the player is on the ground -> Start "standing"
	if player.is_on_floor() \
	and abs(player.velocity).length() < 0.2:
		# Start "standing"
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Check the eyeline for a ledge to grab -> Start "hanging"
	if player.enable_hanging:
		if not player.ray_cast_top.is_colliding() \
		and player.ray_cast_high.is_colliding():
			# Get the collision object
			var collision_object = player.ray_cast_high.get_collider()
			# Check if the collision object is "hangable"
			if not collision_object is CharacterBody3D \
			and not collision_object is SoftBody3D:
				# Start "hanging"
				transition_state(NODE_STATE, States.State.HANGING)
				return
	
	# Ⓑ/[shift] _pressed_ -> Move faster while "climbing"
	if player.enable_sprinting:
		if Input.is_action_pressed(player.controls.button_1):
			player.speed_current = player.speed_climbing * 2
		else:
			player.speed_current = player.speed_climbing

	# Ⓨ/[Ctrl] _pressed_ -> Start "falling"
	if Input.is_action_just_pressed(player.controls.button_3):
		transition_state(NODE_STATE, States.State.FALLING)
		return

	# Move the player while climbing
	move_player()

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Adjust playback speed based on climbing speed
	if player.speed_current > player.speed_climbing:
		player.animation_player.speed_scale = 1.5
	else:
		player.animation_player.speed_scale = 1.0

	# Store the current animation as the target animation
	var target_animation: String = player.animation_player.current_animation

	# Idle when no input
	if player.input_direction == Vector2.ZERO:
		target_animation = ANIMATION_CLIMBING_IDLE
	else:
		# Prefer vertical movement for animation selection
		if abs(player.input_direction.y) > 0.0:
			if player.input_direction.y < 0.0:
				target_animation = ANIMATION_CLIMBING_UP
			else:
				target_animation = ANIMATION_CLIMBING_DOWN
		# Fall back to horizontal shimmy when no vertical input
		elif abs(player.input_direction.x) > 0.0:
			if player.input_direction.x < 0.0:
				target_animation = ANIMATION_CLIMBING_LEFT
			else:
				target_animation = ANIMATION_CLIMBING_RIGHT

	# Apply animation change only if needed to avoid rapid toggling
	if player.animation_player.current_animation != target_animation:
		player.animation_player.current_animation = target_animation


## Start "climbing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.CLIMBING

	# Flag the player as "climbing"
	player.is_climbing = true

	# Set the player's speed
	player.speed_current = player.speed_climbing

	# Reset velocity and virtual velocity
	player.velocity = Vector3.ZERO
	player.virtual_velocity = Vector3.ZERO

	# Move the player to the wall
	move_to_wall()


## Stop "climbing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "climbing"
	player.is_climbing = false

	# Reset animation playback speed
	player.animation_player.speed_scale = 1.0
