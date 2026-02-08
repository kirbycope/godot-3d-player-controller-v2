extends BaseState
class_name Running
## 🏃 Running on the floor.

# Running 🔵 Mixamo animations
const MIX_ANIMATION := "Running/mixamo_com"
const MIX_ANIMATION_BACKWARD := "Running_Backward/mixamo_com"
const MIX_ANIMATION_BACKWARD_FLIP := "Running_Backward_Flip/mixamo_com"
const MIX_ANIMATION_STRAFE_LEFT := "Running_Strafe_Left/mixamo_com"
const MIX_ANIMATION_STRAFE_RIGHT := "Running_Strafe_Right/mixamo_com"
# Running 🔵 Mixamo animations (holding a rifle)
const MIX_ANIMATION_HOLDING_RIFLE := "Running_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_BACKWARD_HOLDING_RIFLE := "Running_Backward_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_STRAFE_LEFT_HOLDING_RIFLE := "Running_Strafe_Left_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_STRAFE_RIGHT_HOLDING_RIFLE := "Running_Strafe_Right_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_AIMING_RIFLE := "Running_Aiming_Rifle/mixamo_com"
const MIX_ANIMATION_FIRING_RIFLE := "Running_Firing_Rifle/mixamo_com"

# Running 🟣 Quaternius animations
const QUAT_ANIMATION := "UAL1/Jog_Fwd"
const QUAT_ANIMATION_BACKWARD := "UAL1/Jog_Bwd"  # Requires [Source] version of UAL1
const QUAT_ANIMATION_STRAFE_LEFT := "UAL1/Jog_Left" # Requires [Source] version of UAL1
const QUAT_ANIMATION_STRAFE_RIGHT := "UAL1/Jog_Right" # Requires [Source] version of UAL1
# Running 🟣 Quaternius animations (holding a rifle)
const QUAT_ANIMATION_HOLDING_RIFLE := MIX_ANIMATION_HOLDING_RIFLE # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_BACKWARD_HOLDING_RIFLE := MIX_ANIMATION_BACKWARD_HOLDING_RIFLE # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_STRAFE_LEFT_HOLDING_RIFLE := MIX_ANIMATION_STRAFE_LEFT_HOLDING_RIFLE # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_STRAFE_RIGHT_HOLDING_RIFLE := MIX_ANIMATION_STRAFE_RIGHT_HOLDING_RIFLE # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_AIMING_RIFLE := MIX_ANIMATION_AIMING_RIFLE # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_FIRING_RIFLE := MIX_ANIMATION_FIRING_RIFLE # There is no Quaternius animation yet (UAl1/UAL2)

const NODE_STATE := States.State.RUNNING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "jumping" or "flipping"
	if event.is_action_pressed(Controls.BUTTON_0):
		if player.enable_jumping \
		and player.is_on_floor() \
		and not player.chat.line_edit.visible:
			if player.enable_flipping \
			and player.is_strafing \
			and (Input.is_action_pressed(Controls.MOVE_DOWN) or Input.is_action_pressed(Controls.MOVE_UP)):
				# Start "flipping"
				transition_state(player.current_state, States.State.FLIPPING)
				return
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
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

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
	# Check if strafing left or right
	var is_strafe_left: bool = player.is_strafing and player.input_direction.x < 0.0
	var is_strafe_right: bool = player.is_strafing and player.input_direction.x > 0.0
	# Check if moving backwards (first-person, while strafing, or while target-locked)
	var is_backpedaling = Input.is_action_pressed(Controls.MOVE_DOWN) \
		and (player.camera.perspective == player.camera.Perspective.FIRST_PERSON \
		or player.is_strafing \
		or player.is_target_locked)
	var mixamo_animation: String ## The name of the Mixamo animation to play.
	var quaternius_animation: String ## The name of the Quaternius animation to play.

	# Handle "running" (while "strafing")
	if is_strafe_left or is_strafe_right:
		# Handle "running" (while "strafing" and holding a rifle)
		if player.is_holding_rifle:
			# Handle "running" (while "strafing" left and holding a rifle)
			if is_strafe_left:
				mixamo_animation = MIX_ANIMATION_STRAFE_LEFT_HOLDING_RIFLE
				quaternius_animation = QUAT_ANIMATION_STRAFE_LEFT_HOLDING_RIFLE
			# Handle "running" (while "strafing" right and holding a rifle)
			elif is_strafe_right:
				mixamo_animation = MIX_ANIMATION_STRAFE_RIGHT_HOLDING_RIFLE
				quaternius_animation = QUAT_ANIMATION_STRAFE_RIGHT_HOLDING_RIFLE
		# Handle "running" (while "strafing" and unarmed)
		else:
			# Handle "running" (while "strafing" left and unarmed)
			if is_strafe_left:
				mixamo_animation = MIX_ANIMATION_STRAFE_LEFT
				quaternius_animation = QUAT_ANIMATION_STRAFE_LEFT
			# Handle "running" (while "strafing" right and unarmed)
			elif is_strafe_right:
				mixamo_animation = MIX_ANIMATION_STRAFE_RIGHT
				quaternius_animation = QUAT_ANIMATION_STRAFE_RIGHT
	# Handle "running" (while backpedaling)
	elif is_backpedaling:
		# Handle "running" (while backpedaling and holding a rifle)
		if player.is_holding_rifle:
			mixamo_animation = MIX_ANIMATION_BACKWARD_HOLDING_RIFLE
			quaternius_animation = QUAT_ANIMATION_BACKWARD_HOLDING_RIFLE
		# Handle "running" (while backpedaling and unarmed)
		else:
			mixamo_animation = MIX_ANIMATION_BACKWARD
			quaternius_animation = QUAT_ANIMATION_BACKWARD
	# Handle "running" (while holding a rifle)
	elif player.is_holding_rifle:
		# Handle "running" (while holding a rifle and firing)
		if player.is_firing_rifle:
			mixamo_animation = MIX_ANIMATION_FIRING_RIFLE
			quaternius_animation = QUAT_ANIMATION_FIRING_RIFLE
		# Handle "running" (while holding a rifle and aiming)
		elif player.is_aiming_rifle:
			mixamo_animation = MIX_ANIMATION_AIMING_RIFLE
			quaternius_animation = QUAT_ANIMATION_AIMING_RIFLE
		# Handle "running" (while holding a rifle)
		else:
			mixamo_animation = MIX_ANIMATION_HOLDING_RIFLE
			quaternius_animation = QUAT_ANIMATION_HOLDING_RIFLE
	# Handle "running" (unarmed)
	else:
		mixamo_animation = MIX_ANIMATION
		quaternius_animation = QUAT_ANIMATION

	# Play the appropriate animation based on the player's animation set (🔵 Mixamo or 🟣 Quaternius)
	var animation = mixamo_animation if player.animation_set == 0 else quaternius_animation
	var current_animation = player.animation_player_current_animation()
	if current_animation != animation:
		_on_animation_finished(current_animation)
		player.animation_player_play(animation)


func _on_animation_finished(animation_name: String) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	if animation_name == MIX_ANIMATION_FIRING_RIFLE \
	or animation_name == QUAT_ANIMATION_FIRING_RIFLE:
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
