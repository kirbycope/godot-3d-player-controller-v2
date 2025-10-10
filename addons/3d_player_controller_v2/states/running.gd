extends BaseState

const ANIMATION_RUNNING := "AnimationLibrary_Godot/Sprint"
const NODE_NAME := "Running"
const NODE_STATE := States.State.RUNNING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if there is no input -> Start "standing"
	if player.input_direction == Vector2.ZERO:
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Check if the player is not moving -> Start "standing"
	if abs(player.velocity).length() < 0.2:
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Check if the player speed is slower than "running" -> Start "walking"
	if player.speed_current < player.speed_running:
		transition_state(NODE_STATE, States.State.WALKING)
		return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if in first person and moving backwards
	var play_backwards = (player.perspective == player.Perspective.FIRST_PERSON) and Input.is_action_pressed(player.controls.move_down)

	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_RUNNING:
		# Play the "running" animation
		if play_backwards:
			player.animation_player.play_backwards(ANIMATION_RUNNING)
		else:
			player.animation_player.play(ANIMATION_RUNNING)


## Start "running".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.RUNNING

	# Flag the player as "running"
	player.is_running = true

	# Set the player's speed
	player.speed_current = player.speed_running


## Stop "running".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "running"
	player.is_running = false
