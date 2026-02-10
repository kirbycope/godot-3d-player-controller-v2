extends BaseState
class_name Standing
## 🚶 Standing still, on the floor.

# Standing 🔵 Mixamo animations
const MIX_ANIMATION_STANDING_IDLE := "Standing/mixamo_com"
const MIX_ANIMATION_STANDING_READY := "Standing_Ready/mixamo_com"
# Standing 🔵 Mixamo animations (holding a fishing rod)
const MIX_ANIMATION_FISHING_CASTING := "Standing_Fishing_Cast/mixamo_com"
const MIX_ANIMATION_FISHING_IDLE := "Standing_Fishing_Idle/mixamo_com"
const MIX_ANIMATION_FISHING_REELING := "Standing_Fishing_Reel/mixamo_com"
# Standing 🔵 Mixamo animations (blocking using held equipment)
const MIX_ANIMATION_BLOCKING_1H_LEFT := "Standing_Blocking_1H_Left/mixamo_com"
const MIX_ANIMATION_BLOCKING_1H_RIGHT := "Standing_Blocking_1H_Right/mixamo_com"
const MIX_ANIMATION_BLOCKING_2H := "Standing_Blocking_2H/mixamo_com"
# Standing 🔵 Mixamo animations (holding equipment)
const MIX_ANIMATION_HOLDING_1H_LEFT := "Standing_Holding_1H_Left/mixamo_com"
const MIX_ANIMATION_HOLDING_1H_RIGHT := "Standing_Holding_1H_Right/mixamo_com"
const MIX_ANIMATION_HOLDING_2H := "Standing_Holding_2H/mixamo_com"
# Standing 🔵 Mixamo animations (kicking)
const MIX_ANIMATION_KICKING_LEFT := "Standing_Kicking_Left/mixamo_com"
const MIX_ANIMATION_KICKING_RIGHT := "Standing_Kicking_Right/mixamo_com"
# Standing 🔵 Mixamo animations (punching)
const MIX_ANIMATION_PUNCHING_LEFT := "Standing_Punching_Left/mixamo_com"
const MIX_ANIMATION_PUNCHING_RIGHT := "Standing_Punching_Right/mixamo_com"
# Standing 🔵 Mixamo animations (sword and shield)
const MIX_ANIMATION_BLOCKING_SWORD_AND_SHIELD := "Standing_Blocking_Sword_And_Shield/mixamo_com"
const MIX_ANIMATION_CASTING_SWORD_AND_SHIELD := "Standing_Casting_Sword_And_Shield/mixamo_com" # TODO: Implement. Casting up into the sky and then crashing weapon hand into the ground.
const MIX_ANIMATION_CASTING_2_SWORD_AND_SHIELD := "Standing_Casting_2_Sword_And_Shield/mixamo_com" # TODO: Implement. Casting forward using shield hand.
const MIX_ANIMATION_HOLDING_SWORD_AND_SHIELD := "Standing_Holding_Sword_And_Shield/mixamo_com"
const MIX_ANIMATION_POWERING_SWORD_AND_SHIELD := "Standing_Powering_Sword_And_Shield/mixamo_com" # TODO: Implement. "Powering Up" by puffing out chest and lowering arms.
const MIX_ANIMATION_SWINGING_SWORD_AND_SHIELD := "Standing_Swinging_Sword_And_Shield/mixamo_com" # TODO: Implement combo 1/3.
const MIX_ANIMATION_SWINGING_2_SWORD_AND_SHIELD := "Standing_Swinging_2_Sword_And_Shield/mixamo_com" # TODO: Implement combo 2/3.
const MIX_ANIMATION_SWINGING_3_SWORD_AND_SHIELD := "Standing_Swinging_3_Sword_And_Shield/mixamo_com" # TODO: Implement combo 3/3.
# Standing 🔵 Mixamo animations (holding a rifle)
const MIX_ANIMATION_HOLDING_RIFLE := "Standing_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_RIFLE_AIMING := "Standing_Aiming_Rifle/mixamo_com"
const MIX_ANIMATION_RIFLE_FIRING := "Standing_Firing_Rifle/mixamo_com"
# Standing 🔵 Mixamo animations (swinging using held equipment, swing a pickaxe or sword)
const MIX_ANIMATION_SWINGING_1H_LEFT := "Standing_Swinging_1H_Left/mixamo_com"
const MIX_ANIMATION_SWINGING_1H_RIGHT := "Standing_Swinging_1H_Right/mixamo_com"
const MIX_ANIMATION_SWINGING_2H := "Standing_Swinging_2H/mixamo_com"
# Standing 🔵 Mixamo animations (throwing)
const MIX_ANIMATION_THROWING_LEFT := "Standing_Throwing_Left/mixamo_com"
const MIX_ANIMATION_THROWING_RIGHT := "Standing_Throwing_Right/mixamo_com"
# Standing 🔵 Mixamo animations (rotating in place)
const MIX_ANIMATION_TURNING_LEFT := "Standing_Left_Turn/mixamo_com" # TODO: Implement
const MIX_ANIMATION_TURNING_RIGHT := "Standing_Right_Turn/mixamo_com" # TODO: Implement

const NODE_STATE := States.State.STANDING

var combo_count := 0 # Current sword-and-shield combo swing step (0 = idle)


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "jumping" or "flipping"
	if event.is_action_pressed(Controls.BUTTON_0):
		if player.enable_jumping and player.is_on_floor() and not player.chat.line_edit.visible:
			if player.enable_flipping and player.is_strafing and (Input.is_action_pressed(Controls.MOVE_DOWN) or Input.is_action_pressed(Controls.MOVE_UP)):
				# Start "flipping"
				transition_state(player.current_state, States.State.FLIPPING)
				return
			else:
				# Start "jumping"
				transition_state(player.current_state, States.State.JUMPING)
				return

	# Ⓑ/[shift] _pressed_ -> Start "sprinting"
	if event.is_action_pressed(Controls.BUTTON_1):
		if player.enable_sprinting and player.input_direction != Vector2.ZERO and player.is_on_floor():
			transition_state(NODE_STATE, States.State.SPRINTING)

	# Do nothing if the mouse is visible (UI is active)
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE \
	or player.camera.is_rotating_camera:
		return

	# 🄻1/[MB0] _pressed_
	if event.is_action_pressed(Controls.BUTTON_4):
		# Fishing "casting"
		if player.is_holding_fishing_rod:
			if not player.is_reeling_fishing:
				player.is_casting_fishing = true
			return
		# Rifle "aiming" 🄻1
		if player.is_holding_rifle:
			if event is InputEventJoypadButton:
				player.is_aiming_rifle = true
		# Rifle "firing" [MB0]
		if player.is_holding_rifle:
			if event is InputEventMouseButton:
				player.is_firing_rifle = true
			return
		# Shield "blocking"
		if player.is_holding_sword_and_shield:
			if not player.is_blocking_sword_and_shield:
				player.is_blocking_sword_and_shield = true
			return
		# Left 1H "swinging"
		if player.is_holding_1h_left:
			if not player.is_swinging_1h_right \
			and not player.is_blocking_1h_left:
				player.is_swinging_1h_left = true
			return
		# Right 1H "blocking"
		if player.is_holding_1h_right:
			if not player.is_blocking_1h_right:
				player.is_blocking_1h_right = true
				player.is_swinging_1h_right = false
			return
		# 2H "swinging"
		if player.is_holding_2h:
			if not player.is_blocking_2h:
				player.is_swinging_2h = true
			return
		# Left hand "throwing" 
		if player.is_holding_left:
			if not player.is_throwing_left:
				player.is_throwing_left = true
			return
		# Left "punching"
		if player.enable_punching:
			if not player.is_punching_left:
				_on_animation_finished(player.animation_player_current_animation()) 
				player.is_punching_left = true
				player.timer_punch_left.start()
			return

	# 🄻1/[MB0] _released_
	if event.is_action_released(Controls.BUTTON_4):
		# Rifle "aiming" 🄻1 release
		if event is InputEventJoypadButton:
			if player.is_holding_rifle:
				player.is_aiming_rifle = false
		# Shield "blocking" release
		if player.is_blocking_sword_and_shield:
			player.is_blocking_sword_and_shield = false
		# Right 1H "blocking" release
		if player.is_blocking_1h_right:
			player.is_blocking_1h_right = false

	# 🄻2/[MB3] _pressed_
	if event.is_action_pressed(Controls.BUTTON_6):
		# Left "kicking"
		if player.enable_kicking \
		and not player.is_kicking_left:
			_on_animation_finished(player.animation_player_current_animation()) 
			player.is_kicking_left = true
			player.timer_kick_left.start()

	# 🅁1/[MB1] _pressed_ 
	if event.is_action_pressed(Controls.BUTTON_5):
		# Held object "throwing"
		if player.enable_throwing \
		and player.camera.item_spring_arm.get_child_count() != 0:
			pass # For now, this prevents the player from "punching" when trying to throw
		# Fishing "reeling"
		if player.is_holding_fishing_rod:
			if not player.is_casting_fishing:
				player.is_reeling_fishing = true
			return
		# Rifle "aiming" [MB1]
		if player.is_holding_rifle:
			if event is InputEventMouseButton:
				player.is_aiming_rifle = true
		# Rifle "firing" 🅁1 (joypad)
		if player.is_holding_rifle:
			if event is InputEventJoypadButton:
				player.is_firing_rifle = true
			return
		# Sword (with shield) "swinging"
		if player.is_holding_sword_and_shield:
			# Queue "combo 1/3" if not currently swinging
			if not player.is_swinging_sword_and_shield:
				player.is_swinging_sword_and_shield = true
				combo_count = 1
			# Queue "combo 2/3" if currently in "combo 1/3"
			elif player.is_swinging_sword_and_shield \
			and combo_count == 1 \
			and player.animation_player_current_animation() == MIX_ANIMATION_SWINGING_SWORD_AND_SHIELD \
			and player.animation_player_current_animation_position() >= player.animation_player_current_animation_length() * 0.5:
				combo_count = 2
			# Queue "combo 3/3" if currently in "combo 2/3"
			elif player.is_swinging_sword_and_shield \
			and combo_count == 2 \
			and player.animation_player_current_animation() == MIX_ANIMATION_SWINGING_2_SWORD_AND_SHIELD \
			and player.animation_player_current_animation_position() >= player.animation_player_current_animation_length() * 0.5:
				combo_count = 3
			return
		# Right 1H "swinging"
		if player.is_holding_1h_right:
			if not player.is_swinging_1h_left \
			and not player.is_blocking_1h_right:
				player.is_swinging_1h_right = true
			return
		# Left 1H "blocking"
		if player.is_holding_1h_left:
			if not player.is_blocking_1h_left:
				player.is_blocking_1h_left = true
				player.is_swinging_1h_left = false
			return
		# 2H "blocking"
		if player.is_holding_2h:
			if not player.is_blocking_2h:
				player.is_blocking_2h = true
				player.is_swinging_2h = false
			return
		# Right hand "throwing" 
		if player.is_holding_right:
			if not player.is_throwing_right:
				player.is_throwing_right = true
			return
		# Right "punching"
		elif player.enable_punching:
			if not player.is_punching_right:
				_on_animation_finished(player.animation_player_current_animation()) 
				player.is_punching_right = true
				player.timer_punch_right.start()
			return

	# 🅁1/[MB1] _released_
	if event.is_action_released(Controls.BUTTON_5):
		# Rifle "aiming" [MB0] release
		if event is InputEventMouseButton:
			if player.is_holding_rifle:
				player.is_aiming_rifle = false
		# Left 1H "blocking" release
		if player.is_blocking_1h_left:
			player.is_blocking_1h_left = false
		# 2H "blocking" release
		if player.is_blocking_2h:
			player.is_blocking_2h = false

	# 🅁2/[MB4] _pressed_
	if event.is_action_pressed(Controls.BUTTON_7):
		# Right "kicking"
		if player.enable_kicking \
		and not player.is_kicking_right:
			_on_animation_finished(player.animation_player_current_animation()) 
			player.is_kicking_right = true
			player.timer_kick_right.start()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Not on floor -> Start "falling"
	if not player.is_on_floor() and not player.ray_cast_below.is_colliding():
		transition_state(player.current_state, States.State.FALLING)

	# Ⓨ/[Ctrl] _pressed_ -> Start "crouching"
	# Not in _input() to allow holding down the button while in other states and transitioning to "standing"
	if Input.is_action_pressed(Controls.BUTTON_3) and not player.pause.visible:
		if player.enable_crouching and player.is_on_floor():
			transition_state(NODE_STATE, States.State.CROUCHING)

	# 🄻1/[MB0] _pressed_ -> Shield "blocking"
	# Not in _input() to allow holding down the button while in other states and transitioning to "standing"
	if Input.is_action_pressed(Controls.BUTTON_4) and not player.pause.visible:
		if player.is_holding_sword_and_shield and not player.is_blocking_sword_and_shield:
			player.is_blocking_sword_and_shield = true

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	var current_animation = player.animation_player_current_animation()
	
	# 🦵 -- Kicking animations --
	if player.enable_kicking and player.is_kicking_left:
		var animation = MIX_ANIMATION_KICKING_LEFT
		if current_animation != animation:
			_on_animation_finished(current_animation)
			player.animation_player_play(animation)
			if player.character.has_method("play_attack_long_sound_effect"):
				player.character.play_attack_long_sound_effect()
	elif player.enable_kicking and player.is_kicking_right:
		var animation = MIX_ANIMATION_KICKING_RIGHT
		if current_animation != animation:
			_on_animation_finished(current_animation)
			player.animation_player_play(animation)
			if player.character.has_method("play_attack_long_sound_effect"):
				player.character.play_attack_long_sound_effect()

	# 🎣 -- Fishing animations --
	elif player.is_holding_fishing_rod:
		var animation: String
		if player.is_casting_fishing:
			animation = MIX_ANIMATION_FISHING_CASTING
		elif player.is_reeling_fishing:
			animation = MIX_ANIMATION_FISHING_REELING
		else:
			animation = MIX_ANIMATION_FISHING_IDLE
		if current_animation != animation:
			_on_animation_finished(current_animation)
			player.animation_player_play(animation)

	# 🔫 -- Rifle animations --
	elif player.is_holding_rifle:
		var animation: String
		if player.is_firing_rifle:
			animation = MIX_ANIMATION_RIFLE_FIRING
		elif player.is_aiming_rifle:
			animation = MIX_ANIMATION_RIFLE_AIMING
		else:
			animation = MIX_ANIMATION_HOLDING_RIFLE
		if current_animation != animation:
			_on_animation_finished(current_animation)
			player.animation_player_play(animation)

	#  🗡️ -- Sword and Shield -- 🛡️
	elif player.is_holding_sword_and_shield:
		var animation: String
		if player.is_swinging_sword_and_shield:
			if combo_count == 2:
				animation = MIX_ANIMATION_SWINGING_2_SWORD_AND_SHIELD
			elif combo_count == 3:
				animation = MIX_ANIMATION_SWINGING_3_SWORD_AND_SHIELD
			else:
				animation = MIX_ANIMATION_SWINGING_SWORD_AND_SHIELD
			if current_animation != animation:
				if current_animation not in [
					MIX_ANIMATION_SWINGING_SWORD_AND_SHIELD,
					MIX_ANIMATION_SWINGING_2_SWORD_AND_SHIELD,
					MIX_ANIMATION_SWINGING_3_SWORD_AND_SHIELD
				]:
					_on_animation_finished(current_animation)
				player.animation_player_play(animation)
				if player.character.has_method("play_attack_short_sound_effect"):
					player.character.play_attack_short_sound_effect()
		elif player.is_blocking_sword_and_shield:
			animation = MIX_ANIMATION_BLOCKING_SWORD_AND_SHIELD
			if current_animation != animation:
				player.animation_player_play(animation)
		else:
			animation = MIX_ANIMATION_HOLDING_SWORD_AND_SHIELD
			if current_animation != animation:
				player.animation_player_play(animation)

	# 🛠️ -- 1H animations -- ⚔️
	elif player.is_holding_1h_left and player.is_holding_1h_right:
		var animation: String
		if player.is_swinging_1h_left:
			animation = MIX_ANIMATION_SWINGING_1H_LEFT
			if current_animation != animation:
				_on_animation_finished(current_animation)
				player.animation_player_play(animation)
				if player.character.has_method("play_attack_short_sound_effect"):
					player.character.play_attack_short_sound_effect()
		elif player.is_swinging_1h_right:
			animation = MIX_ANIMATION_SWINGING_1H_RIGHT
			if current_animation != animation:
				_on_animation_finished(current_animation)
				player.animation_player_play(animation)
				if player.character.has_method("play_attack_short_sound_effect"):
					player.character.play_attack_short_sound_effect()
		else:
			animation = MIX_ANIMATION_HOLDING_1H_RIGHT
			if current_animation != animation:
				player.animation_player_play(animation)
	elif player.is_holding_1h_left:
		var animation: String
		if player.is_blocking_1h_left:
			animation = MIX_ANIMATION_BLOCKING_1H_LEFT
		elif player.is_swinging_1h_left:
			animation = MIX_ANIMATION_SWINGING_1H_LEFT
		else:
			animation = MIX_ANIMATION_HOLDING_1H_LEFT
		if current_animation != animation:
			if player.is_swinging_1h_left:
				_on_animation_finished(current_animation)
				if player.character.has_method("play_attack_short_sound_effect"):
					player.character.play_attack_short_sound_effect()
			else:
				_on_animation_finished(current_animation)
			player.animation_player_play(animation)
	elif player.is_holding_1h_right:
		var animation: String
		if player.is_blocking_1h_right:
			animation = MIX_ANIMATION_BLOCKING_1H_RIGHT
		elif player.is_swinging_1h_right:
			animation = MIX_ANIMATION_SWINGING_1H_RIGHT
		else:
			animation = MIX_ANIMATION_HOLDING_1H_RIGHT
		if current_animation != animation:
			if player.is_swinging_1h_right:
				_on_animation_finished(current_animation)
				if player.character.has_method("play_attack_short_sound_effect"):
					player.character.play_attack_short_sound_effect()
			else:
				_on_animation_finished(current_animation)
			player.animation_player_play(animation)

	# 👐 -- 2H animations --
	elif player.is_holding_2h:
		var animation: String
		if player.is_blocking_2h:
			animation = MIX_ANIMATION_BLOCKING_2H
		elif player.is_swinging_2h:
			animation = MIX_ANIMATION_SWINGING_2H
		else:
			animation = MIX_ANIMATION_HOLDING_2H
		if current_animation != animation:
			if player.is_swinging_2h:
				_on_animation_finished(current_animation)
				if player.character.has_method("play_attack_long_sound_effect"):
					player.character.play_attack_long_sound_effect()
			else:
				_on_animation_finished(current_animation)
			player.animation_player_play(animation)

	# 🤾 -- Throwing animations --
	elif player.is_holding_left and player.is_throwing_left:
		var animation = MIX_ANIMATION_THROWING_LEFT
		if current_animation != animation:
			_on_animation_finished(current_animation)
			player.animation_player_play(animation)
	elif player.is_holding_right and player.is_throwing_right:
		var animation = MIX_ANIMATION_THROWING_RIGHT
		if current_animation != animation:
			_on_animation_finished(current_animation)
			player.animation_player_play(animation)

	# 🥊 -- Punching animations --
	elif player.enable_punching and player.is_punching_left:
		var animation = MIX_ANIMATION_PUNCHING_LEFT
		if current_animation != animation:
			_on_animation_finished(current_animation)
			player.animation_player_play(animation)
			if player.character.has_method("play_attack_short_sound_effect"):
				player.character.play_attack_short_sound_effect()
	elif player.enable_punching and player.is_punching_right:
		var animation = MIX_ANIMATION_PUNCHING_RIGHT
		if current_animation != animation:
			_on_animation_finished(current_animation)
			player.animation_player_play(animation)
			if player.character.has_method("play_attack_short_sound_effect"):
				player.character.play_attack_short_sound_effect()

	# ✋ -- Unarmed animation --
	else:
		var animation: String
		if player.is_target_locked:
			animation = MIX_ANIMATION_STANDING_READY
		else:
			animation = MIX_ANIMATION_STANDING_IDLE
		if current_animation != animation:
			_on_animation_finished(current_animation)
			player.animation_player_play(animation)


## Resets the related state flag when an animation is finished.
func _on_animation_finished(animation_name: String) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	if animation_name == MIX_ANIMATION_FISHING_CASTING:
		player.is_casting_fishing = false
	elif animation_name == MIX_ANIMATION_FISHING_REELING:
		player.is_reeling_fishing = false
	elif animation_name == MIX_ANIMATION_KICKING_LEFT:
		player.is_kicking_left = false
	elif animation_name == MIX_ANIMATION_KICKING_RIGHT:
		player.is_kicking_right = false
	elif animation_name == MIX_ANIMATION_RIFLE_FIRING:
		player.is_firing_rifle = false
	elif animation_name == MIX_ANIMATION_PUNCHING_LEFT:
		player.is_punching_left = false
	elif animation_name == MIX_ANIMATION_PUNCHING_RIGHT:
		player.is_punching_right = false
	elif animation_name == MIX_ANIMATION_SWINGING_1H_LEFT:
		player.is_swinging_1h_left = false
	elif animation_name == MIX_ANIMATION_SWINGING_1H_RIGHT:
		player.is_swinging_1h_right = false
	elif animation_name == MIX_ANIMATION_SWINGING_2H:
		player.is_swinging_2h = false
	elif animation_name == MIX_ANIMATION_SWINGING_SWORD_AND_SHIELD:
		player.is_swinging_sword_and_shield = false
	elif animation_name == MIX_ANIMATION_SWINGING_2_SWORD_AND_SHIELD:
		player.is_swinging_sword_and_shield = false
	elif animation_name == MIX_ANIMATION_SWINGING_3_SWORD_AND_SHIELD:
		player.is_swinging_sword_and_shield = false
	elif animation_name == MIX_ANIMATION_THROWING_LEFT:
		player.is_throwing_left = false
	elif animation_name == MIX_ANIMATION_THROWING_RIGHT:
		player.is_throwing_right = false


## Start "standing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.STANDING

	# Flag the player as "standing"
	player.is_standing = true

	# Set the player's speed
	player.speed_current = 0.0

	# Set the player's velocity
	player.velocity = Vector3.ZERO
	player.virtual_velocity = Vector3.ZERO

	# Connect animation finished signal
	if not player.animation_player_is_connected("animation_finished", _on_animation_finished):
		player.animation_player_connect("animation_finished", _on_animation_finished)


## Stop "standing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "standing"
	player.is_standing = false

	# Clear state specific flags
	_on_animation_finished(player.animation_player_current_animation()) 

	# Disconnect animation finished signal
	if player.animation_player_is_connected("animation_finished", _on_animation_finished):
		player.animation_player_disconnect("animation_finished", _on_animation_finished)

	# Ensure all state flags are cleared (precautionary)
	player.is_aiming_rifle = false
	player.is_firing_rifle = false
	player.is_casting_fishing = false
	player.is_reeling_fishing = false
	player.is_blocking_1h_left = false
	player.is_blocking_1h_right = false	
	player.is_blocking_2h = false
	player.is_blocking_sword_and_shield = false
	player.is_swinging_sword_and_shield = false
	player.is_kicking_left = false
	player.is_kicking_right = false
	player.is_punching_left = false
	player.is_punching_right = false
	player.is_swinging_1h_left = false
	player.is_swinging_1h_right = false
	player.is_swinging_2h = false
	player.is_throwing_left = false
	player.is_throwing_right = false
