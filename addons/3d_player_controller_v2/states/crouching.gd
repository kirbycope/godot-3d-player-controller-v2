extends BaseState

const ANIMATION_CROUCHING_IDLE := "Crouching/mixamo_com"
const ANIMATION_CROUCHING_HOLDING_RIFLE := "Crouching_Holding_Rifle/mixamo_com"
const ANIMATION_CROUCHING_AIMING := "Crouching_Aiming_Rifle/mixamo_com"
const ANIMATION_CROUCHING_FIRING := "Crouching_Firing_Rifle/mixamo_com"
const NODE_NAME := "Crouching"
const NODE_STATE := States.State.CROUCHING


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

	# Ⓨ/[Ctrl] _released_ -> Start "standing"
	if event.is_action_released(player.controls.button_3):
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# 🄻1/[MB0] _pressed_ -> Fire rifle
	if event.is_action_pressed(player.controls.button_4):
		if player.is_holding_rifle:
			player.is_firing_rifle = true

	# 🅁1/[MB1] _pressed_ -> Aim rifle
	if event.is_action_pressed(player.controls.button_5):
		if player.is_holding_rifle:
			player.is_aiming_rifle = true

	# 🅁1/[MB1] _released_ -> Lower rifle
	if event.is_action_released(player.controls.button_5):
		if player.is_holding_rifle \
		and player.is_aiming_rifle:
			player.is_aiming_rifle = false


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if the player is moving -> Start "crawling"
	if player.enable_crawling:
		if player.input_direction != Vector2.ZERO:
			transition_state(NODE_STATE, States.State.CRAWLING)
			return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# -- Rifle animations --
	if player.is_holding_rifle:
		if player.is_firing_rifle:
			if player.animation_player.current_animation != ANIMATION_CROUCHING_FIRING:
				player.animation_player.play(ANIMATION_CROUCHING_FIRING)
				player.animation_player.connect("animation_finished", _on_animation_finished)
		elif player.is_aiming_rifle:
			if player.animation_player.current_animation != ANIMATION_CROUCHING_AIMING:
				player.animation_player.play(ANIMATION_CROUCHING_AIMING)
		else:
			if player.animation_player.current_animation != ANIMATION_CROUCHING_HOLDING_RIFLE:
				player.animation_player.play(ANIMATION_CROUCHING_HOLDING_RIFLE)

	# -- Unarmed animation --
	else:
		if player.animation_player.current_animation != ANIMATION_CROUCHING_IDLE:
			player.animation_player.play(ANIMATION_CROUCHING_IDLE)


func _on_animation_finished(animation_name: String) -> void:
	player.animation_player.disconnect("animation_finished", _on_animation_finished)
	if animation_name == ANIMATION_CROUCHING_FIRING:
		player.is_firing_rifle = false


## Start "crouching".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.CROUCHING

	# Flag the player as "crouching"
	player.is_crouching = true

	# Set the player's speed
	player.speed_current = 0.0

	# Set the player's velocity
	player.velocity = Vector3.ZERO

	# Set the player collision shape's height
	player.collision_shape.shape.height = player.collision_height / 2

	# Set the player collision shape's position
	player.collision_shape.position = player.collision_position / 2


## Stop "crouching".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "crouching"
	player.is_crouching = false

	# [Re]set the player collision shape's height
	player.collision_shape.shape.height = player.collision_height
	
	# [Re]set the player collision shape's position
	player.collision_shape.position = player.collision_position
