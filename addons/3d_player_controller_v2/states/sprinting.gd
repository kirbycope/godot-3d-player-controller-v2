extends BaseState

const ANIMATION_SPRINTING := "AnimationLibrary_Godot/Jog_Fwd"
const NODE_NAME := "Sprtinting"
const NODE_STATE := States.State.SPRINTING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Ⓨ/[Ctrl] _pressed_ -> Start "sliding"
	if player.enable_sliding:
		if Input.is_action_pressed(player.controls.button_3) \
		and player.is_on_floor():
			transition_state(NODE_STATE, States.State.SLIDING)
			return

	# Ⓑ/[shift] _just_released_ -> Start "standing"
	if Input.is_action_just_released(player.controls.button_1):
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if in first person and moving backwards
	var play_backwards = (player.camera.perspective == player.camera.Perspective.FIRST_PERSON) and Input.is_action_pressed(player.controls.move_down)

	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_SPRINTING:
		# Play the "sprinting" animation
		if play_backwards:
			player.animation_player.play_backwards(ANIMATION_SPRINTING)
		else:
			player.animation_player.play(ANIMATION_SPRINTING)


## Start "sprinting".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.SPRINTING

	# Flag the player as "sprinting"
	player.is_sprinting = true

	# Set the player's speed
	player.speed_current = player.speed_sprinting


## Stop "sprinting".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "sprinting"
	player.is_sprinting = false
