extends BaseState

const ANIMATION_SPRINTING := "Sprinting/mixamo_com"
const ANIMATION_SPRINTING_HOLDING_RIFLE := "Sprinting_Holding_Rifle/mixamo_com"
const NODE_NAME := "Sprinting"
const NODE_STATE := States.State.SPRINTING


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "jumping"
	if event.is_action_pressed(player.controls.button_0):
		if player.enable_jumping \
		and player.is_on_floor():
			player.base_state.transition_state(player.current_state, States.State.JUMPING)

	# Ⓑ/[shift] _released_ -> Start "standing"
	if event.is_action_released(player.controls.button_1):
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Ⓨ/[Ctrl] _pressed_ -> Start "sliding"
	if player.enable_sliding:
		if event.is_action_pressed(player.controls.button_3) \
		and player.is_on_floor():
			transition_state(NODE_STATE, States.State.SLIDING)
			return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if in first person and moving backwards
	var play_backwards = (player.camera.perspective == player.camera.Perspective.FIRST_PERSON) and Input.is_action_pressed(player.controls.move_down)

	# -- Rifle animations --
	if player.is_holding_rifle:
		if player.animation_player.current_animation != ANIMATION_SPRINTING_HOLDING_RIFLE:
			if play_backwards:
				player.animation_player.play_backwards(ANIMATION_SPRINTING_HOLDING_RIFLE)
			else:
				player.animation_player.play(ANIMATION_SPRINTING_HOLDING_RIFLE)

	# -- Unarmed animations --
	else:
		if player.animation_player.current_animation != ANIMATION_SPRINTING:
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
