extends BaseState

const ANIMATION_RUNNING := "Running_In_Place/mixamo_com"
const ANIMATION_RUNNING_HOLDING_RIFLE := "Rifle_Run_In_Place/mixamo_com"
const ANIMATION_RUNNING_AIMING_RIFLE := "Rifle_Run_In_Place_Running/mixamo_com"
const ANIMATION_RUNNING_FIRING_RIFLE := "Firing_Rifle_In_Place_Running/mixamo_com"
const NODE_NAME := "Running"
const NODE_STATE := States.State.RUNNING


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

	# Ⓑ/[shift] _pressed_ -> Start "sprinting"
	if event.is_action_pressed(player.controls.button_1):
		if player.enable_sprinting\
		and player.input_direction != Vector2.ZERO \
		and player.is_on_floor():
			transition_state(NODE_STATE, States.State.SPRINTING)
			return

	# 🄻1/[MB0] _pressed_
	if event.is_action_pressed(player.controls.button_4):
		# Rifle "firing"
		if player.is_holding_rifle:
			player.is_firing_rifle = true

	# 🅁1/[MB1] _pressed_ 
	if event.is_action_pressed(player.controls.button_5):
		# Rifle "aiming"
		if player.is_holding_rifle:
			player.is_aiming_rifle = true

	# 🅁1/[MB1] _released_
	if event.is_action_released(player.controls.button_5):
		# Stop "aiming rifle"
		if player.is_holding_rifle \
		and player.is_aiming_rifle:
			player.is_aiming_rifle = false


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if there is no input -> Start "standing"
	if player.input_direction == Vector2.ZERO:
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if in first person and moving backwards
	var play_backwards = (player.camera.perspective == player.camera.Perspective.FIRST_PERSON) and Input.is_action_pressed(player.controls.move_down)

	# -- Rifle animations --
	if player.is_holding_rifle:
		if player.is_firing_rifle:
			if player.animation_player.current_animation != ANIMATION_RUNNING_FIRING_RIFLE:
				if play_backwards:
					player.animation_player.play_backwards(ANIMATION_RUNNING_FIRING_RIFLE)
				else:
					player.animation_player.play(ANIMATION_RUNNING_FIRING_RIFLE)
				player.animation_player.connect("animation_finished", _on_animation_finished)
		elif player.is_aiming_rifle:
			if player.animation_player.current_animation != ANIMATION_RUNNING_AIMING_RIFLE:
				if play_backwards:
					player.animation_player.play_backwards(ANIMATION_RUNNING_AIMING_RIFLE)
				else:
					player.animation_player.play(ANIMATION_RUNNING_AIMING_RIFLE)
		else:	
			if player.animation_player.current_animation != ANIMATION_RUNNING_HOLDING_RIFLE:
				if play_backwards:
					player.animation_player.play_backwards(ANIMATION_RUNNING_HOLDING_RIFLE)
				else:
					player.animation_player.play(ANIMATION_RUNNING_HOLDING_RIFLE)

	# -- Unarmed animations --
	else:
		if player.animation_player.current_animation != ANIMATION_RUNNING:
			if play_backwards:
				player.animation_player.play_backwards(ANIMATION_RUNNING)
			else:
				player.animation_player.play(ANIMATION_RUNNING)


func _on_animation_finished(animation_name: String) -> void:
	# Disconnect the signal to avoid multiple connections
	player.animation_player.disconnect("animation_finished", _on_animation_finished)
	if animation_name == ANIMATION_RUNNING_FIRING_RIFLE:
		player.is_firing_rifle = false


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
