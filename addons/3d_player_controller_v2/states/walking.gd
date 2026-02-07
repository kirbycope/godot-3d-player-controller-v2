extends BaseState
class_name Walking
## 🚶 Walking on the floor.

# Walking 🔵 Mixamo animations
const MIX_ANIMATION_WALKING := "Walking/mixamo_com"
const MIX_ANIMATION_WALKING_HOLDING_RIFLE := "Walking_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_WALKING_HOLDING_AIMING := "Walking_Aiming_Rifle/mixamo_com"
const MIX_ANIMATION_WALKING_FIRING_RIFLE := "Walking_Firing_Rifle/mixamo_com"
# Walking 🟣 Quaternius animations
const QUAT_ANIMATION_WALKING := "UAL1/Walk"
const QUAT_ANIMATION_WALKING_HOLDING_RIFLE := "UAL1/Walk_Holding_Rifle" # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_WALKING_HOLDING_AIMING := "UAL1/Walk_Holding_Aiming" # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_WALKING_FIRING_RIFLE := "UAL1/Walk_Firing_Rifle" # There is no Quaternius animation yet (UAl1/UAL2)
const NODE_STATE := States.State.WALKING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "jumping" or "flipping"
	if event.is_action_pressed(Controls.BUTTON_0):
		if player.enable_jumping \
		and player.is_on_floor() \
		and not player.chat.line_edit.visible:
			if player.is_target_locked \
			and player.enable_flipping \
			and (Input.is_action_pressed(Controls.MOVE_DOWN) or Input.is_action_pressed(Controls.MOVE_UP)):
				# Start "flipping"
				transition_state(player.current_state, States.State.FLIPPING)
			else:
				# Start "jumping"
				transition_state(player.current_state, States.State.JUMPING)
			return

	# Ⓑ/[shift] _pressed_ -> Start "sprinting"
	if event.is_action_pressed(Controls.BUTTON_1):
		if player.enable_sprinting \
		and player.input_direction != Vector2.ZERO \
		and player.is_on_floor():
			transition_state(NODE_STATE, States.State.SPRINTING)
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

	# Not on floor -> Start "falling"
	if not player.is_on_floor() \
	and not player.ray_cast_below.is_colliding():
		transition_state(player.current_state, States.State.FALLING)
		return

	# Check if there is no input -> Start "standing"
	if player.input_direction == Vector2.ZERO:
		transition_state(NODE_STATE, States.State.STANDING)
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
			mix_anim = MIX_ANIMATION_WALKING_FIRING_RIFLE
			quat_anim = QUAT_ANIMATION_WALKING_FIRING_RIFLE
		else:
			mix_anim = MIX_ANIMATION_WALKING_HOLDING_RIFLE
			quat_anim = QUAT_ANIMATION_WALKING_HOLDING_RIFLE
	else:
		mix_anim = MIX_ANIMATION_WALKING
		quat_anim = QUAT_ANIMATION_WALKING

	if player.animation_set == 0:
		if player.animation_player_current_animation() != mix_anim:
			_on_animation_finished(player.animation_player_current_animation())
			if play_backwards:
				player.animation_player_play_backwards(mix_anim)
			else:
				player.animation_player_play(mix_anim)
	elif player.animation_set == 1:
		if player.animation_player_current_animation() != quat_anim:
			_on_animation_finished(player.animation_player_current_animation())
			if play_backwards:
				player.animation_player_play_backwards(quat_anim)
			else:
				player.animation_player_play(quat_anim)


func _on_animation_finished(animation_name: String) -> void:
	if animation_name == MIX_ANIMATION_WALKING_FIRING_RIFLE \
	or animation_name == QUAT_ANIMATION_WALKING_FIRING_RIFLE:
		player.is_firing_rifle = false


## Start "walking".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.WALKING

	# Flag the player as "walking"
	player.is_walking = true

	# Set the player's speed
	player.speed_current = player.speed_walking

	# Connect animation finished signal
	player.animation_player_connect("animation_finished", _on_animation_finished)


## Stop "walking".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "walking"
	player.is_walking = false

	# Clear state specific flags
	_on_animation_finished(player.animation_player_current_animation()) 

	# Disconnect animation finished signal
	if player.animation_player_is_connected("animation_finished", _on_animation_finished):
		player.animation_player_disconnect("animation_finished", _on_animation_finished)
