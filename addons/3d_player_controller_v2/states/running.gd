extends BaseState
class_name Running
## 🏃 Running on the floor.

# Running 🔵 Mixamo animations
const MIX_ANIMATION_RUNNING := "Running/mixamo_com"
const MIX_ANIMATION_RUNNING_BACKWARDS := "Running_Backward/mixamo_com"
const MIX_ANIMATION_RUNNING_STRAFE_LEFT := "Running_Strafe_Left/mixamo_com"
const MIX_ANIMATION_RUNNING_STRAFE_RIGHT := "Running_Strafe_Right/mixamo_com"
# Running 🔵 Mixamo animations (while holding a rifle)
const MIX_ANIMATION_RUNNING_HOLDING_RIFLE := "Running_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_RUNNING_BACKWARDS_HOLDING_RIFLE := "Running_Backward_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_RUNNING_STRAFE_LEFT_HOLDING_RIFLE := "Running_Strafe_Left_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_RUNNING_STRAFE_RIGHT_HOLDING_RIFLE := "Running_Strafe_Right_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_RUNNING_AIMING_RIFLE := "Running_Aiming_Rifle/mixamo_com"
const MIX_ANIMATION_RUNNING_FIRING_RIFLE := "Running_Firing_Rifle/mixamo_com"

# Running 🟣 Quaternius animations
const QUAT_ANIMATION_RUNNING := "UAL1/Jog_Fwd"
const QUAT_ANIMATION_RUNNING_BACKWARDS := "UAL1/Jog_Bwd"  # Requires [Source] version of UAL1
const QUAT_ANIMATION_RUNNING_STRAFE_LEFT := "UAL1/Jog_Left" # Requires [Source] version of UAL1
const QUAT_ANIMATION_RUNNING_STRAFE_RIGHT := "UAL1/Jog_Right" # Requires [Source] version of UAL1
# Running 🟣 Quaternius animations (while holding a rifle)
const QUAT_ANIMATION_RUNNING_HOLDING_RIFLE := "Running_Holding_Rifle/mixamo_com" # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_RUNNING_BACKWARDS_HOLDING_RIFLE := "Running_Backward_Holding_Rifle/mixamo_com" # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_RUNNING_STRAFE_LEFT_HOLDING_RIFLE := "Running_Strafe_Left_Holding_Rifle/mixamo_com" # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_RUNNING_STRAFE_RIGHT_HOLDING_RIFLE := "Running_Strafe_Right_Holding_Rifle/mixamo_com" # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_RUNNING_AIMING_RIFLE := "Running_Aiming_Rifle/mixamo_com" # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_RUNNING_FIRING_RIFLE := "Running_Firing_Rifle/mixamo_com" # There is no Quaternius animation yet (UAl1/UAL2)

const NODE_STATE := States.State.RUNNING


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
			return

	# Ⓑ/[shift] _pressed_ -> Start "sprinting"
	if event.is_action_pressed(Controls.BUTTON_1):
		if player.enable_sprinting\
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
	var is_strafe_left: bool = player.is_strafing and player.input_direction.x < 0.0
	var is_strafe_right: bool = player.is_strafing and player.input_direction.x > 0.0
	# Check if moving backwards (first-person, or backpedaling while strafing)
	var is_backpedaling = (player.camera.perspective == player.camera.Perspective.FIRST_PERSON and Input.is_action_pressed(Controls.MOVE_DOWN)) \
		or (player.enable_strafing and player.is_backpedaling)
	var mix_anim: String
	var quat_anim: String
	if player.is_strafing:
		if player.is_holding_rifle:
			if is_strafe_left:
				mix_anim = MIX_ANIMATION_RUNNING_STRAFE_LEFT_HOLDING_RIFLE
				quat_anim = QUAT_ANIMATION_RUNNING_STRAFE_LEFT_HOLDING_RIFLE
			else:
				mix_anim = MIX_ANIMATION_RUNNING_STRAFE_RIGHT_HOLDING_RIFLE
				quat_anim = QUAT_ANIMATION_RUNNING_STRAFE_RIGHT_HOLDING_RIFLE
		else:
			if is_strafe_left:
				mix_anim = MIX_ANIMATION_RUNNING_STRAFE_LEFT
				quat_anim = QUAT_ANIMATION_RUNNING_STRAFE_LEFT
			else:
				mix_anim = MIX_ANIMATION_RUNNING_STRAFE_RIGHT
				quat_anim = QUAT_ANIMATION_RUNNING_STRAFE_RIGHT
	elif is_backpedaling:
		if player.is_holding_rifle:
			mix_anim = MIX_ANIMATION_RUNNING_BACKWARDS_HOLDING_RIFLE
			quat_anim = QUAT_ANIMATION_RUNNING_BACKWARDS_HOLDING_RIFLE
		else:
			mix_anim = MIX_ANIMATION_RUNNING_BACKWARDS
			quat_anim = QUAT_ANIMATION_RUNNING_BACKWARDS
	elif player.is_holding_rifle:
		if player.is_firing_rifle:
			mix_anim = MIX_ANIMATION_RUNNING_FIRING_RIFLE
			quat_anim = QUAT_ANIMATION_RUNNING_FIRING_RIFLE
		elif player.is_aiming_rifle:
			mix_anim = MIX_ANIMATION_RUNNING_AIMING_RIFLE
			quat_anim = QUAT_ANIMATION_RUNNING_AIMING_RIFLE
		else:
			mix_anim = MIX_ANIMATION_RUNNING_HOLDING_RIFLE
			quat_anim = QUAT_ANIMATION_RUNNING_HOLDING_RIFLE
	else:
		mix_anim = MIX_ANIMATION_RUNNING
		quat_anim = QUAT_ANIMATION_RUNNING

	if player.animation_set == 0:
		if player.animation_player_current_animation() != mix_anim:
			_on_animation_finished(player.animation_player_current_animation())
			player.animation_player_play(mix_anim)
	elif player.animation_set == 1:
		if player.animation_player_current_animation() != quat_anim:
			_on_animation_finished(player.animation_player_current_animation())
			player.animation_player_play(quat_anim)


func _on_animation_finished(animation_name: String) -> void:
	if animation_name == MIX_ANIMATION_RUNNING_FIRING_RIFLE \
	or animation_name == QUAT_ANIMATION_RUNNING_FIRING_RIFLE:
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

	# Connect animation finished signal
	player.animation_player_connect("animation_finished", _on_animation_finished)


## Stop "running".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "running"
	player.is_running = false

	# Clear state specific flags
	_on_animation_finished(player.animation_player_current_animation()) 

	# Disconnect animation finished signal
	if player.animation_player_is_connected("animation_finished", _on_animation_finished):
		player.animation_player_disconnect("animation_finished", _on_animation_finished)
