extends BaseState
class_name Crawling
## 🥷 Crawling on the floor. Crouching if the player is holding a rifle.

# Crawling 🔵 Mixamo animations
const MIX_ANIMATION_CRAWLING := "Crawling/mixamo_com"
const MIX_ANIMATION_CRAWLING_HOLDING_RIFLE := "Crouching_Walking_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_CRAWLING_AIMING_RIFLE := "Crouching_Walking_Aiming_Rifle/mixamo_com"
const MIX_ANIMATION_CRAWLING_FIRING_RIFLE := "Crouching_Firing_Rifle/mixamo_com"
# Crawling 🟣 Quaternius animations
const QUAT_ANIMATION_CRAWLING := "UAL1/Crawl_Fwd"
const QUAT_ANIMATION_CRAWLING_HOLDING_RIFLE := "Crouching_Walking_Holding_Rifle/mixamo_com" # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_CRAWLING_AIMING_RIFLE := "Crouching_Walking_Aiming_Rifle/mixamo_com" # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_CRAWLING_FIRING_RIFLE := "Crouching_Firing_Rifle/mixamo_com" # There is no Quaternius animation yet (UAl1/UAL2)

const NODE_STATE := States.State.CRAWLING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "rolling"
	if player.enable_rolling:
		if event.is_action_pressed(Controls.BUTTON_0):
			transition_state(NODE_STATE, States.State.ROLLING)
			return

	# Ⓨ/[Ctrl] _released_ -> Start "standing"
	if event.is_action_released(Controls.BUTTON_3):
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# 🄻1/[MB0] _pressed_
	if event.is_action_pressed(Controls.BUTTON_4):
		# Rifle "aiming" 🄻1
		if player.is_holding_rifle \
		and event is InputEventJoypadButton:
			player.is_aiming_rifle = true
		# Rifle "firing" [MB0]
		elif player.is_holding_rifle \
		and event is InputEventMouseButton:
			player.is_firing_rifle = true

	# 🄻1 _released_ -> Lower rifle
	if event.is_action_released(Controls.BUTTON_4) \
	and event is InputEventJoypadButton:
		# Rifle "aiming" 🄻1
		if player.is_holding_rifle:
			player.is_aiming_rifle = false

	# 🅁1/[MB1] _pressed_ -> Aim rifle
	if event.is_action_pressed(Controls.BUTTON_5):
		# Rifle "aiming" [MB1]
		if player.is_holding_rifle \
		and event is InputEventMouseButton:
			player.is_aiming_rifle = true
		# Rifle "firing" 🅁1 (joypad)
		elif player.is_holding_rifle \
		and event is InputEventJoypadButton:
			player.is_firing_rifle = true

	# [MB1] _released_ -> Lower rifle
	if event.is_action_released(Controls.BUTTON_5) \
	and event is InputEventMouseButton:
		if player.is_holding_rifle:
			player.is_aiming_rifle = false


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if there is no input (but still crouching) -> Start "crouching"
	if player.input_direction == Vector2.ZERO \
	and Input.is_action_pressed(Controls.BUTTON_3) \
	and not player.pause.visible:
		transition_state(NODE_STATE, States.State.CROUCHING)
		return
	
	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if in first person and moving backwards
	var play_backwards = (player.camera.perspective == player.camera.Perspective.FIRST_PERSON) and Input.is_action_pressed(Controls.MOVE_DOWN)
	var mix_anim: String
	var quat_anim: String
	if player.is_holding_rifle:
		if player.is_firing_rifle:
			mix_anim = MIX_ANIMATION_CRAWLING_FIRING_RIFLE
			quat_anim = QUAT_ANIMATION_CRAWLING_FIRING_RIFLE
		elif player.is_aiming_rifle:
			mix_anim = MIX_ANIMATION_CRAWLING_AIMING_RIFLE
			quat_anim = QUAT_ANIMATION_CRAWLING_AIMING_RIFLE
		else:
			mix_anim = MIX_ANIMATION_CRAWLING_HOLDING_RIFLE
			quat_anim = QUAT_ANIMATION_CRAWLING_HOLDING_RIFLE
	else:
		mix_anim = MIX_ANIMATION_CRAWLING
		quat_anim = QUAT_ANIMATION_CRAWLING

	if player.animation_set == 0:
		if player.animation_player_current_animation() != mix_anim:
			if play_backwards:
				player.animation_player_play_backwards(mix_anim)
			else:
				_on_animation_finished(player.animation_player_current_animation())
				player.animation_player_play(mix_anim)
	elif player.animation_set == 1:
		if player.animation_player_current_animation() != quat_anim:
			if play_backwards:
				player.animation_player_play_backwards(quat_anim)
			else:
				_on_animation_finished(player.animation_player_current_animation())
				player.animation_player_play(quat_anim)


func _on_animation_finished(animation_name: String) -> void:
	if animation_name == MIX_ANIMATION_CRAWLING_FIRING_RIFLE \
	or animation_name == QUAT_ANIMATION_CRAWLING_FIRING_RIFLE:
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

	# Connect animation finished signal
	if not player.animation_player_is_connected("animation_finished", _on_animation_finished):
		player.animation_player_connect("animation_finished", _on_animation_finished)


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

	# Clear state specific flags
	_on_animation_finished(player.animation_player_current_animation())

	# Disconnect animation finished signal
	if player.animation_player_is_connected("animation_finished", _on_animation_finished):
		player.animation_player_disconnect("animation_finished", _on_animation_finished)
