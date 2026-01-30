extends BaseState
class_name Crouching
## 🥷 Crouching down.

# Crouching 🔵 Mixamo animations
const MIX_ANIMATION_CROUCHING_IDLE := "Crouching/mixamo_com"
const MIX_ANIMATION_CROUCHING_HOLDING_RIFLE := "Crouching_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_CROUCHING_AIMING := "Crouching_Aiming_Rifle/mixamo_com"
const MIX_ANIMATION_CROUCHING_FIRING := "Crouching_Firing_Rifle/mixamo_com"
# Crouching 🟣 Quaternius animations
const QUAT_ANIMATION_CROUCHING_IDLE := "AnimationLibrary_Godot/Crouch_Idle"
const QUAT_ANIMATION_CROUCHING_HOLDING_RIFLE := "Crouching_Holding_Rifle/mixamo_com" # TODO: Replace with actual Quaternius animation name
const QUAT_ANIMATION_CROUCHING_AIMING := "Crouching_Aiming_Rifle/mixamo_com" # TODO: Replace with actual Quaternius animation name
const QUAT_ANIMATION_CROUCHING_FIRING := "Crouching_Firing_Rifle/mixamo_com" # TODO: Replace with actual Quaternius animation name

const NODE_STATE := States.State.CROUCHING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "jumping"
	if event.is_action_pressed(Controls.BUTTON_0):
		if player.enable_jumping \
		and player.is_on_floor() \
		and not player.chat.line_edit.visible:
			transition_state(player.current_state, States.State.JUMPING)

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

	# Check if the player is moving -> Start "crawling"
	if player.enable_crawling:
		if player.input_direction != Vector2.ZERO:
			transition_state(NODE_STATE, States.State.CRAWLING)
			return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	var mix_anim: String
	var quat_anim: String
	if player.is_holding_rifle:
		if player.is_firing_rifle:
			mix_anim = MIX_ANIMATION_CROUCHING_FIRING
			quat_anim = QUAT_ANIMATION_CROUCHING_FIRING
		elif player.is_aiming_rifle:
			mix_anim = MIX_ANIMATION_CROUCHING_AIMING
			quat_anim = QUAT_ANIMATION_CROUCHING_AIMING
		else:
			mix_anim = MIX_ANIMATION_CROUCHING_HOLDING_RIFLE
			quat_anim = QUAT_ANIMATION_CROUCHING_HOLDING_RIFLE
	else:
		mix_anim = MIX_ANIMATION_CROUCHING_IDLE
		quat_anim = QUAT_ANIMATION_CROUCHING_IDLE

	if player.animation_set == 0:
		if player.animation_player_current_animation() != mix_anim:
			_on_animation_finished(player.animation_player_current_animation())
			player.animation_player_play(mix_anim)
	elif player.animation_set == 1:
		if player.animation_player_current_animation() != quat_anim:
			_on_animation_finished(player.animation_player_current_animation())
			player.animation_player_play(quat_anim)


func _on_animation_finished(animation_name: String) -> void:
	if animation_name == MIX_ANIMATION_CROUCHING_FIRING \
	or animation_name == QUAT_ANIMATION_CROUCHING_FIRING:
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

	# Connect animation finished signal
	player.animation_player_connect("animation_finished", _on_animation_finished)


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

	# Clear state specific flags
	_on_animation_finished(player.animation_player_current_animation())

	# Disconnect animation finished signal
	if player.animation_player_is_connected("animation_finished", _on_animation_finished):
		player.animation_player_disconnect("animation_finished", _on_animation_finished)
