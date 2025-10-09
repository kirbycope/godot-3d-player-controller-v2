extends BaseState

const ANIMATION_STANDING := "AnimationLibrary_Godot/Idle"
const NODE_NAME := "Standing"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the player is moving
	if player.velocity != Vector3.ZERO:
		# Check if the player is not on a floor
		if !player.is_on_floor():
			# Start "falling"
			transition(NODE_NAME, "Falling")
		# Check if the player is holding the "sprint" button
		elif Input.is_action_pressed(player.controls.button_1):
			# Start "sprinting"
			transition(NODE_NAME, "Sprinting")
		# Check if the player is slower than or equal to "walking"
		elif (0.0 < player.speed_current) and (player.speed_current <= player.speed_walking):
			# Start "walking"
			transition(NODE_NAME, "Walking")
		# Check if the player speed is faster than "walking" but slower than or equal to "running"
		elif (player.speed_walking < player.speed_current) and (player.speed_current <= player.speed_running):
			# Start "running"
			transition(NODE_NAME, "Running")
	# Check if the player is "standing"
	if player.is_standing:
		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_STANDING:
		# Play the "standing idle" animation
		player.animation_player.play(ANIMATION_STANDING)


## Start "standing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = States.State.STANDING
	# Flag the player as "standing"
	player.is_standing = true
	# Set the player's speed
	player.speed_current = player.speed_walking
	# Set the player's velocity
	player.velocity = Vector3.ZERO


## Stop "standing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# Flag the player as not "standing"
	player.is_standing = false
