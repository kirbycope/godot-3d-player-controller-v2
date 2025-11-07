extends BaseState

const ANIMATION_FALLING := "Falling/mixamo_com"
const ANIMATION_FALLING_HOLDING_RIFLE := "Falling_Holding_Rifle/mixamo_com"
const NODE_NAME := "Falling"
const NODE_STATE := States.State.FALLING


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
			transition_state(player.current_state, States.State.JUMPING)
			return

	# Ⓐ/[Space] _pressed_ -> Start "flying"
	if event.is_action_pressed(player.controls.button_0):
		if player.enable_flying:
			transition_state(player.current_state, States.State.FLYING)
			return

	# Ⓐ/[Space] _pressed_ -> Start "paragliding"
	if event.is_action_pressed(player.controls.button_0):
		if player.enable_paragliding:
			transition_state(player.current_state, States.State.PARAGLIDING)
			return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if the player is on a floor
	if player.is_on_floor():
		# Fell too fast -> Start "ragdolling"
		if player.virtual_velocity.y < -player.gravity:
			transition_state(NODE_STATE, States.State.RAGDOLLING)
			return
		# Fell safely -> Start "standing"
		else:
			transition_state(NODE_STATE, States.State.STANDING)
			return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# -- Rifle animations --
	if player.is_holding_rifle:
		if player.animation_player.current_animation != ANIMATION_FALLING_HOLDING_RIFLE:
			player.animation_player.play(ANIMATION_FALLING_HOLDING_RIFLE)

	# -- Unarmed animations --
	else:
		if player.animation_player.current_animation != ANIMATION_FALLING:
			player.animation_player.play(ANIMATION_FALLING)


## Start "falling".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.FALLING

	# Flag the player as "falling"
	player.is_falling = true


## Stop "falling".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "falling"
	player.is_falling = false
