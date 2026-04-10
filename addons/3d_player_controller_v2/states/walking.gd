extends BaseState
class_name Walking
## 🚶 Walking on the floor.

# Walking 🔵 Mixamo animations
const MIX_ANIMATION := "Walking/mixamo_com"
const MIX_ANIMATION_BACKWARD := "Walking_Backward/mixamo_com"
const MIX_ANIMATION_BACKWARD_FLIP := Running.MIX_ANIMATION_BACKWARD_FLIP
const MIX_ANIMATION_STRAFE_LEFT := "Walking_Strafe_Left/mixamo_com"
const MIX_ANIMATION_STRAFE_RIGHT := "Walking_Strafe_Right/mixamo_com"
# Walking 🔵 Mixamo animations (sword and shield)
const MIX_ANIMATION_SWORD_AND_SHIELD := "Walking_Sword_And_Shield/mixamo_com"
const MIX_ANIMATION_BACKWARD_SWORD_AND_SHIELD := "Walking_Backward_Sword_And_Shield/mixamo_com"
const MIX_ANIMATION_BACKWARD_FLIP_SWORD_AND_SHIELD := Running.MIX_ANIMATION_BACKWARD_FLIP 
const MIX_ANIMATION_STRAFE_LEFT_SWORD_AND_SHIELD := "Walking_Strafe_Left_Sword_And_Shield/mixamo_com"
const MIX_ANIMATION_STRAFE_RIGHT_SWORD_AND_SHIELD := "Walking_Strafe_Right_Sword_And_Shield/mixamo_com"
# Walking 🔵 Mixamo animations (holding a rifle)
const MIX_ANIMATION_HOLDING_RIFLE := "Walking_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_BACKWARD_HOLDING_RIFLE := "Walking_Backward_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_STRAFE_LEFT_HOLDING_RIFLE := "Walking_Strafe_Left_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_STRAFE_RIGHT_HOLDING_RIFLE := "Walking_Strafe_Right_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_AIMING_RIFLE := "Walking_Aiming_Rifle/mixamo_com"
const MIX_ANIMATION_FIRING_RIFLE := "Walking_Firing_Rifle/mixamo_com"

const NODE_STATE := States.State.WALKING


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
			and not player.is_riding \
			and (Input.is_action_pressed(Controls.MOVE_DOWN) or Input.is_action_pressed(Controls.MOVE_UP)):
				# Start "flipping"
				transition_state(player.current_state, States.State.FLIPPING)
				return
			else:
				# Start "jumping"
				transition_state(player.current_state, States.State.JUMPING)
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
	var current_animation = player.animation_player_current_animation()
	var target_animation: String

	# 🐎 -- Riding animations --
	if player.is_riding:
		var animation = Sitting.MIX_ANIMATION_SITTING
		if current_animation != animation:
			player.animation_player_play(animation)
		return

	# Check if strafing left or right
	var is_strafe_left: bool = player.is_strafing and player.input_direction.x < 0.0
	var is_strafe_right: bool = player.is_strafing and player.input_direction.x > 0.0
	# Check if moving backwards (first-person, while strafing, or while target-locked)
	var is_backpedaling = Input.is_action_pressed(Controls.MOVE_DOWN) \
		and (player.camera.perspective == player.camera.Perspective.FIRST_PERSON \
		or player.is_strafing \
		or player.is_target_locked)

	# Handle "walking" (while "strafing")
	if is_strafe_left or is_strafe_right:
		# Handle "walking" (while "strafing" and holding a rifle)
		if player.is_holding_rifle:
			# Handle "walking" (while "strafing" left and holding a rifle)
			if is_strafe_left:
				target_animation = MIX_ANIMATION_STRAFE_LEFT_HOLDING_RIFLE
			# Handle "walking" (while "strafing" right and holding a rifle)
			elif is_strafe_right:
				target_animation = MIX_ANIMATION_STRAFE_RIGHT_HOLDING_RIFLE
		# Handle "walking" (while "strafing" and holding a shield)
		elif player.is_holding_shield_1h_left:
			# Handle "walking" (while "strafing" left and holding a shield)
			if is_strafe_left:
				target_animation = MIX_ANIMATION_STRAFE_LEFT_SWORD_AND_SHIELD
			# Handle "walking" (while "strafing" right and holding a shield)
			elif is_strafe_right:
				target_animation = MIX_ANIMATION_STRAFE_RIGHT_SWORD_AND_SHIELD
		# Handle "walking" (while "strafing" and unarmed)
		else:
			# Handle "walking" (while "strafing" left and unarmed)
			if is_strafe_left:
				target_animation = MIX_ANIMATION_STRAFE_LEFT
			# Handle "walking" (while "strafing" right and unarmed)
			elif is_strafe_right:
				target_animation = MIX_ANIMATION_STRAFE_RIGHT
	# Handle "walking" (while backpedaling)
	elif is_backpedaling:
		# Handle "walking" (while backpedaling and holding a rifle)
		if player.is_holding_rifle:
			target_animation = MIX_ANIMATION_BACKWARD_HOLDING_RIFLE
		# Handle "walking" (while backpedaling and holding a shield)
		elif player.is_holding_shield_1h_left:
			target_animation = MIX_ANIMATION_BACKWARD_SWORD_AND_SHIELD
		# Handle "walking" (while backpedaling and unarmed)
		else:
			target_animation = MIX_ANIMATION_BACKWARD
	# Handle "walking" (while holding a rifle)
	elif player.is_holding_rifle:
		# Handle "walking" (while holding a rifle and firing)
		if player.is_firing_rifle:
			target_animation = MIX_ANIMATION_FIRING_RIFLE
		# Handle "walking" (while holding a rifle and aiming)
		elif player.is_aiming_rifle:
			target_animation = MIX_ANIMATION_AIMING_RIFLE
		# Handle "walking" (while holding a rifle)
		else:
			target_animation = MIX_ANIMATION_HOLDING_RIFLE
	# Handle "walking" (while holding a shield)
	elif player.is_holding_shield_1h_left:
		target_animation = MIX_ANIMATION_SWORD_AND_SHIELD
	# Handle "walking" (unarmed)
	else:
		target_animation = MIX_ANIMATION

	if current_animation != target_animation:
		_on_animation_finished(current_animation)
		player.animation_player_play(target_animation)


func _on_animation_finished(animation_name: String) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	if animation_name == MIX_ANIMATION_FIRING_RIFLE:
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
