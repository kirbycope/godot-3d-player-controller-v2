extends BaseState

const ANIMATION_CRAWLING := "Crawling_In_Place/mixamo_com"
const ANIMATION_CRAWLING_HOLDING_RIFLE := "Rifle_Crouch_Walk_In_Place/mixamo_com"
const ANIMATION_CRAWLING_AIMING_RIFLE := "Crouched_Walking/mixamo_com"
const ANIMATION_CRAWLING_FIRING_RIFLE := "Firing_Rifle_In_Place_Crawling/mixamo_com"
const NODE_NAME := "Crawling"
const NODE_STATE := States.State.CRAWLING


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "rolling"
	if player.enable_rolling:
		if event.is_action_pressed(player.controls.button_0):
			transition_state(NODE_STATE, States.State.ROLLING)
			return

	# Ⓨ/[Ctrl] _released_ -> Start "standing"
	if event.is_action_released(player.controls.button_3):
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# 🄻1/[MB0] _pressed_ -> Fire rifle
	if event.is_action_pressed(player.controls.button_4):
		# Rifle "firing"
		if player.is_holding_rifle:
			player.is_firing_rifle = true

	# 🅁1/[MB1] _pressed_ -> Aim rifle
	if event.is_action_pressed(player.controls.button_5):
		# Rifle "aiming"
		if player.is_holding_rifle:
			player.is_aiming_rifle = true

	# 🅁1/[MB1] _released_ -> Lower rifle
	if event.is_action_released(player.controls.button_5):
		# Stop "aiming rifle"
		if player.is_holding_rifle \
		and player.is_aiming_rifle:
			player.is_aiming_rifle = false


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if there is no input (but still crouching) -> Start "crouching"
	if player.input_direction == Vector2.ZERO \
	and Input.is_action_pressed(player.controls.button_3):
		transition_state(NODE_STATE, States.State.CROUCHING)
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
			if player.animation_player.current_animation != ANIMATION_CRAWLING_FIRING_RIFLE:
				if play_backwards:
					player.animation_player.play_backwards(ANIMATION_CRAWLING_FIRING_RIFLE)
				else:
					player.animation_player.play(ANIMATION_CRAWLING_FIRING_RIFLE)
				player.animation_player.connect("animation_finished", _on_animation_finished)
		elif player.is_aiming_rifle:
			if player.animation_player.current_animation != ANIMATION_CRAWLING_AIMING_RIFLE:
				if play_backwards:
					player.animation_player.play_backwards(ANIMATION_CRAWLING_AIMING_RIFLE)
				else:
					player.animation_player.play(ANIMATION_CRAWLING_AIMING_RIFLE)
		else:
			if player.animation_player.current_animation != ANIMATION_CRAWLING_HOLDING_RIFLE:
				if play_backwards:
					player.animation_player.play_backwards(ANIMATION_CRAWLING_HOLDING_RIFLE)
				else:
					player.animation_player.play(ANIMATION_CRAWLING_HOLDING_RIFLE)

	# -- Unarmed animation --
	else:
		if player.animation_player.current_animation != ANIMATION_CRAWLING:
			if play_backwards:
				player.animation_player.play_backwards(ANIMATION_CRAWLING)
			else:
				player.animation_player.play(ANIMATION_CRAWLING)


func _on_animation_finished(animation_name: String) -> void:
	# Disconnect the signal to avoid multiple connections
	player.animation_player.disconnect("animation_finished", _on_animation_finished)
	if animation_name == ANIMATION_CRAWLING_FIRING_RIFLE:
		player.is_firing_rifle = false


## Start "crawling".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.CRAWLING

	# Flag the player as "crawling"
	player.is_crawling = true

	# Set the player's speed
	player.speed_current = player.speed_crawling

	# Set the player collision shape's height
	#player.collision_shape.shape.height = player.collision_height / 2

	# Set the player collision shape's rotation
	player.collision_shape.rotation.x = deg_to_rad(90)

	# Set the player collision shape's position
	player.collision_shape.position = player.collision_position / 3
	player.collision_shape.position.z += player.collision_height / 3


## Stop "crawling".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "crawling"
	player.is_crawling = false

	# [Re]set the player collision shape's height
	#player.collision_shape.shape.height = player.collision_height

	# [Re]set the player collision shape's rotation
	player.collision_shape.rotation.x = deg_to_rad(0)

	# [Re]set the player collision shape's position
	player.collision_shape.position = player.collision_position
