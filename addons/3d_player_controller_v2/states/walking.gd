extends BaseState

const ANIMATION_WALKING := "AnimationLibrary_Godot/Walk"
const NODE_NAME := "Walking"


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the player is not moving
	if abs(player.velocity).length() < 0.2:
		# Start "standing"
		transition(NODE_NAME, "Standing")
	# Check if the player is not on a floor
	if !player.is_on_floor():
		# Start "falling"
		transition(NODE_NAME, "Falling")
	# [sprint] button _pressed_
	if Input.is_action_pressed(player.controls.button_1):
		# Start "sprinting"
		transition(NODE_NAME, "Sprinting")
	# Check if the player speed is faster than "walking" but slower than or equal to "running"
	if player.speed_walking < player.speed_current and player.speed_current <= player.speed_running:
		# Start "running"
		transition(NODE_NAME, "Running")
	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if in first person and moving backwards
	var play_backwards = (player.perspective == player.Perspective.THIRD_PERSON) and Input.is_action_pressed(player.controls.move_down)
	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_WALKING:
		# Play the "walking" animation
		if play_backwards:
			player.animation_player.play_backwards(ANIMATION_WALKING)
		else:
			player.animation_player.play(ANIMATION_WALKING)


## Start "walking".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = States.State.WALKING
	# Flag the player as "walking"
	player.is_walking = true
	# Set the player's speed
	player.speed_current = player.speed_walking


## Stop "walking".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# Flag the player as not "walking"
	player.is_walking = false
