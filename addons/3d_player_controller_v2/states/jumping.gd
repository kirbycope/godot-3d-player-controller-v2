extends BaseState

const ANIMATION_JUMPING := "Falling/mixamo_com"
const ANIMATION_JUMPING_HOLDING_RIFLE := "Falling_Holding_Rifle/mixamo_com"
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
			if player.ray_cast_high.is_colliding():
				var collision_object = player.ray_cast_high.get_collider()
				if not collision_object is CharacterBody3D \
				and not collision_object is SoftBody3D:
					transition_state(player.current_state, States.State.CLIMBING)
					return

	# Ⓐ/[Space] _pressed_ -> Start "double-jumping"
	if event.is_action_pressed(player.controls.button_0):
		if player.enable_double_jumping \
		and not player.is_double_jumping:
			player.is_double_jumping = true
			player.velocity += player.up_direction * player.speed_jumping
			return

	# Ⓐ/[Space] _pressed_ -> Start "flying"
	if event.is_action_pressed(player.controls.button_0):
		if player.enable_flying:
			transition_state(player.current_state, States.State.FLYING)
			return

	# Ⓐ/[Space] _pressed_ -> Start "paragliding"
	if event.is_action_pressed(player.controls.button_0) \
	and not player.is_on_floor():
		if player.enable_paragliding:
			transition_state(player.current_state, States.State.PARAGLIDING)
			return

	# 🄻1/[MB0] _pressed_
	if event.is_action_pressed(player.controls.button_4):
		# Rifle "aiming" 🄻1
		if player.is_holding_rifle \
		and event is InputEventJoypadButton:
			player.is_aiming_rifle = true
		# Rifle "firing" [MB0]
		elif player.is_holding_rifle \
		and event is InputEventMouseButton:
			player.is_firing_rifle = true

	# 🄻1 _released_ -> Lower rifle
	if event.is_action_released(player.controls.button_4) \
	and event is InputEventJoypadButton:
		# Rifle "aiming" 🄻1
		if player.is_holding_rifle:
			player.is_aiming_rifle = false

	# 🅁1/[MB1] _pressed_ -> Aim rifle
	if event.is_action_pressed(player.controls.button_5):
		# Rifle "aiming" [MB1]
		if player.is_holding_rifle \
		and event is InputEventMouseButton:
			player.is_aiming_rifle = true
		# Rifle "firing" 🅁1 (joypad)
		elif player.is_holding_rifle \
		and event is InputEventJoypadButton:
			player.is_firing_rifle = true

	# [MB1] _released_ -> Lower rifle
	if event.is_action_released(player.controls.button_5) \
	and event is InputEventMouseButton:
		if player.is_holding_rifle:
			player.is_aiming_rifle = false


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
	# -- Rifle animations --
	if player.is_holding_rifle:
		if player.animation_player.current_animation != ANIMATION_JUMPING_HOLDING_RIFLE:
			player.animation_player.play(ANIMATION_JUMPING_HOLDING_RIFLE)

	# -- Unarmed animations --
	else:
		if player.animation_player.current_animation != ANIMATION_JUMPING:
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
