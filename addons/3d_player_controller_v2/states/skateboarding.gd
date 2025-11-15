extends BaseState

## Handles skateboarding movement with ollie jump, speed variations (slow/normal/fast), sprint boost, and dynamic collision shape adjustments.

const ANIMATION_SKATEBOARDING := "Skateboarding/mixamo_com"
const ANIMATION_SKATEBOARDING_FAST := "Skateboarding_Fast/mixamo_com"
const ANIMATION_SKATEBOARDING_SLOW := "Skateboarding_Slow/mixamo_com"
const NODE_NAME := "Skateboarding"
const NODE_STATE := States.State.SKATEBOARDING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ (while grounded) -> Perform "ollie"
	if event.is_action_pressed(player.controls.button_0)\
	and player.is_on_floor():
		# Increase the player's velocity in the up direction
		player.velocity += player.up_direction * player.speed_jumping


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return


	# Ⓑ/[shift] _pressed_ -> Move faster while "skateboarding"
	if player.enable_sprinting \
	and not player.pause.visible:
		if Input.is_action_pressed(player.controls.button_1):
			player.speed_current = player.speed_skateboarding * 1.5
		else:
			player.speed_current = player.speed_skateboarding

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	if player.input_direction == Vector2.ZERO:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_SKATEBOARDING_SLOW:
			player.animation_player.play(ANIMATION_SKATEBOARDING_SLOW)
			# [Re]set the player collision shape's height
			player.collision_shape.shape.height = player.collision_height
			# [Re]set the player collision shape's position
			player.collision_shape.position = player.collision_position
	elif player.speed_current == player.speed_skateboarding:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_SKATEBOARDING:
			player.animation_player.play(ANIMATION_SKATEBOARDING)
			# Set the player collision shape's height
			player.collision_shape.shape.height = player.collision_height * 0.95
			# Set the player collision shape's position
			player.collision_shape.position = player.collision_position * 0.95
	elif player.speed_current > player.speed_skateboarding:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_SKATEBOARDING_FAST:
			player.animation_player.play(ANIMATION_SKATEBOARDING_FAST)
			# Set the player collision shape's height
			player.collision_shape.shape.height = player.collision_height * 0.9
			# Set the player collision shape's position
			player.collision_shape.position = player.collision_position * 0.9


## Start "skateboarding".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.SKATEBOARDING

	# Flag the player as "skateboarding"
	player.is_skateboarding = true

	# Set the player's speed
	player.speed_current = player.speed_skateboarding


## Stop "skateboarding".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "skateboarding"
	player.is_skateboarding = false

	# [Re]set the player collision shape's height
	player.collision_shape.shape.height = player.collision_height

	# [Re]set the player collision shape's position
	player.collision_shape.position = player.collision_position
