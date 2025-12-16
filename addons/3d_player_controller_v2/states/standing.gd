extends BaseState
## Handles standing idle state with support for fishing, punching, kicking, rifle aiming/firing, melee swinging, and throwing animations


const ANIMATION_FISHING_CASTING := "Standing_Fishing_Cast/mixamo_com"
const ANIMATION_FISHING_IDLE := "Standing_Fishing_Idle/mixamo_com"
const ANIMATION_FISHING_REELING := "Standing_Fishing_Reel/mixamo_com"
const ANIMATION_BLOCKING_1H_LEFT := "Standing_Blocking_1H_Left/mixamo_com"
const ANIMATION_BLOCKING_1H_RIGHT := "Standing_Blocking_1H_Right/mixamo_com"
const ANIMATION_BLOCKING_2H := "Standing_Blocking_2H/mixamo_com"
const ANIMATION_HOLDING_1H_LEFT := "Standing_Holding_1H_Left/mixamo_com"
const ANIMATION_HOLDING_1H_RIGHT := "Standing_Holding_1H_Right/mixamo_com"
const ANIMATION_HOLDING_2H := "Standing_Holding_2H/mixamo_com"
const ANIMATION_KICKING_LEFT := "Standing_Kicking_Left/mixamo_com"
const ANIMATION_KICKING_RIGHT := "Standing_Kicking_Right/mixamo_com"
const ANIMATION_PUNCHING_LEFT := "Standing_Punching_Left/mixamo_com"
const ANIMATION_PUNCHING_RIGHT := "Standing_Punching_Right/mixamo_com"
const ANIMATION_HOLDING_RIFLE := "Standing_Holding_Rifle/mixamo_com"
const ANIMATION_RIFLE_AIMING := "Standing_Aiming_Rifle/mixamo_com"
const ANIMATION_RIFLE_FIRING := "Standing_Firing_Rifle/mixamo_com"
const ANIMATION_STANDING_IDLE := "Standing/mixamo_com"
const ANIMATION_SWINGING_1H_LEFT := "Standing_Swinging_1H_Left/mixamo_com"
const ANIMATION_SWINGING_1H_RIGHT := "Standing_Swinging_1H_Right/mixamo_com"
const ANIMATION_SWINGING_2H := "Standing_Swinging_2H/mixamo_com"
const ANIMATION_THROWING_LEFT := "Standing_Throwing_Left/mixamo_com"
const ANIMATION_THROWING_RIGHT := "Standing_Throwing_Right/mixamo_com"
const NODE_NAME := "Standing"
const NODE_STATE := States.State.STANDING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "jumping"
	if event.is_action_pressed(player.controls.button_0):
		if player.enable_jumping \
		and player.is_on_floor() \
		and not player.chat.line_edit.visible:
			transition_state(player.current_state, States.State.JUMPING)

	# Ⓑ/[shift] _pressed_ -> Start "sprinting"
	if event.is_action_pressed(player.controls.button_1):
		if player.enable_sprinting \
		and player.input_direction != Vector2.ZERO \
		and player.is_on_floor():
			transition_state(NODE_STATE, States.State.SPRINTING)
			return

	# 🄻1/[MB0] _pressed_
	if event.is_action_pressed(player.controls.button_4):
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
	if event.is_action_released(player.controls.button_4):
		# Rifle "aiming" 🄻1 release
		if event is InputEventJoypadButton:
			if player.is_holding_rifle:
				player.is_aiming_rifle = false
		# Right 1H "blocking" release
		if player.is_blocking_1h_right:
			player.is_blocking_1h_right = false

	# 🄻2/[MB3] _pressed_
	if event.is_action_pressed(player.controls.button_6):
		# Left "kicking"
		if player.enable_kicking \
		and not player.is_kicking_left:
			_on_animation_finished(player.animation_player_current_animation()) 
			player.is_kicking_left = true
			player.timer_kick_left.start()

	# 🅁1/[MB1] _pressed_ 
	if event.is_action_pressed(player.controls.button_5):
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
	if event.is_action_released(player.controls.button_5):
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
	if event.is_action_pressed(player.controls.button_7):
		# Right "kicking"
		if player.enable_kicking \
		and not player.is_kicking_right:
			_on_animation_finished(player.animation_player_current_animation()) 
			player.is_kicking_right = true
			player.timer_kick_right.start()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Not on floor -> Start "falling"
	if not player.is_on_floor() \
	and not player.ray_cast_below.is_colliding():
		transition_state(player.current_state, States.State.FALLING)
		return

	# Ⓨ/[Ctrl] _pressed_ -> Start "crouching"
	# Not in _input() to allow holding down the button while in other states and trasitioning to "standing"
	if Input.is_action_pressed(player.controls.button_3) \
	and not player.pause.visible:
		if player.enable_crouching \
		and player.is_on_floor():
			transition_state(NODE_STATE, States.State.CROUCHING)
			return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# 🦵 -- Kicking animations --
	if player.enable_kicking \
	and player.is_kicking_left:
		if player.animation_player_current_animation() != ANIMATION_KICKING_LEFT:
			_on_animation_finished(player.animation_player_current_animation()) 
			player.animation_player_play(ANIMATION_KICKING_LEFT)
	elif player.enable_kicking \
	and player.is_kicking_right:
		if player.animation_player_current_animation() != ANIMATION_KICKING_RIGHT:
			_on_animation_finished(player.animation_player_current_animation()) 
			player.animation_player_play(ANIMATION_KICKING_RIGHT)

	# 🎣 -- Fishing animations --
	elif player.is_holding_fishing_rod:
		if player.is_casting_fishing:
			if player.animation_player_current_animation() != ANIMATION_FISHING_CASTING:
				_on_animation_finished(player.animation_player_current_animation()) 
				player.animation_player_play(ANIMATION_FISHING_CASTING)
		elif player.is_reeling_fishing:
			if player.animation_player_current_animation() != ANIMATION_FISHING_REELING:
				_on_animation_finished(player.animation_player_current_animation()) 
				player.animation_player_play(ANIMATION_FISHING_REELING)
		else:
			if player.animation_player_current_animation() != ANIMATION_FISHING_IDLE:
				_on_animation_finished(player.animation_player_current_animation()) 
				player.animation_player_play(ANIMATION_FISHING_IDLE)

	# 🔫 -- Rifle animations --
	elif player.is_holding_rifle:
		if player.is_firing_rifle:
			if player.animation_player_current_animation() != ANIMATION_RIFLE_FIRING:
				_on_animation_finished(player.animation_player_current_animation()) 
				player.animation_player_play(ANIMATION_RIFLE_FIRING)
		elif player.is_aiming_rifle:
			if player.animation_player_current_animation() != ANIMATION_RIFLE_AIMING:
				_on_animation_finished(player.animation_player_current_animation()) 
				player.animation_player_play(ANIMATION_RIFLE_AIMING)
		else:
			if player.animation_player_current_animation() != ANIMATION_HOLDING_RIFLE:
				_on_animation_finished(player.animation_player_current_animation()) 
				player.animation_player_play(ANIMATION_HOLDING_RIFLE)

	# 🛠️ -- 1H animations --
	elif player.is_holding_1h_left \
	and player.is_holding_1h_right:
		if player.is_swinging_1h_left:
			if player.animation_player_current_animation() != ANIMATION_SWINGING_1H_LEFT:
				_on_animation_finished(player.animation_player_current_animation()) 
				player.animation_player_play(ANIMATION_SWINGING_1H_LEFT)
		elif player.is_swinging_1h_right:	
			if player.animation_player_current_animation() != ANIMATION_SWINGING_1H_RIGHT:
				_on_animation_finished(player.animation_player_current_animation()) 
				player.animation_player_play(ANIMATION_SWINGING_1H_RIGHT)
		elif player.animation_player_current_animation() != ANIMATION_HOLDING_1H_RIGHT:
			player.animation_player_play(ANIMATION_HOLDING_1H_RIGHT)
	elif player.is_holding_1h_left:
		if player.is_blocking_1h_left:
			if player.animation_player_current_animation() != ANIMATION_BLOCKING_1H_LEFT:
				player.animation_player_play(ANIMATION_BLOCKING_1H_LEFT)
		elif player.is_swinging_1h_left:
			if player.animation_player_current_animation() != ANIMATION_SWINGING_1H_LEFT:
				_on_animation_finished(player.animation_player_current_animation()) 
				player.animation_player_play(ANIMATION_SWINGING_1H_LEFT)
		elif player.animation_player_current_animation() != ANIMATION_HOLDING_1H_LEFT:
			player.animation_player_play(ANIMATION_HOLDING_1H_LEFT)
	elif player.is_holding_1h_right:
		if player.is_blocking_1h_right:
			if player.animation_player_current_animation() != ANIMATION_BLOCKING_1H_RIGHT:
				player.animation_player_play(ANIMATION_BLOCKING_1H_RIGHT)
		elif player.is_swinging_1h_right:
			if player.animation_player_current_animation() != ANIMATION_SWINGING_1H_RIGHT:
				_on_animation_finished(player.animation_player_current_animation()) 
				player.animation_player_play(ANIMATION_SWINGING_1H_RIGHT)
		elif player.animation_player_current_animation() != ANIMATION_HOLDING_1H_RIGHT:
			player.animation_player_play(ANIMATION_HOLDING_1H_RIGHT)

	# 👐 -- 2H animations --
	elif player.is_holding_2h:
		if player.is_blocking_2h:
			if player.animation_player_current_animation() != ANIMATION_BLOCKING_2H:
				player.animation_player_play(ANIMATION_BLOCKING_2H)
		elif player.is_swinging_2h:
			if player.animation_player_current_animation() != ANIMATION_SWINGING_2H:
				_on_animation_finished(player.animation_player_current_animation()) 
				player.animation_player_play(ANIMATION_SWINGING_2H)
		elif player.animation_player_current_animation() != ANIMATION_HOLDING_2H:
			player.animation_player_play(ANIMATION_HOLDING_2H)

	# 🤾 -- Throwing animations --
	elif player.is_holding_left \
	and player.is_throwing_left:
		if player.animation_player_current_animation() != ANIMATION_THROWING_LEFT:
			_on_animation_finished(player.animation_player_current_animation()) 
			player.animation_player_play(ANIMATION_THROWING_LEFT)
	elif player.is_holding_right \
	and player.is_throwing_right:
		if player.animation_player_current_animation() != ANIMATION_THROWING_RIGHT:
			_on_animation_finished(player.animation_player_current_animation()) 
			player.animation_player_play(ANIMATION_THROWING_RIGHT)

	# 🥊 -- Punching animations --
	elif player.enable_punching \
	and player.is_punching_left:
		if player.animation_player_current_animation() != ANIMATION_PUNCHING_LEFT:
			_on_animation_finished(player.animation_player_current_animation()) 
			player.animation_player_play(ANIMATION_PUNCHING_LEFT)
	elif player.enable_punching \
	and player.is_punching_right:
		if player.animation_player_current_animation() != ANIMATION_PUNCHING_RIGHT:
			_on_animation_finished(player.animation_player_current_animation()) 
			player.animation_player_play(ANIMATION_PUNCHING_RIGHT)

	# ✋ -- Unarmed animation --
	else:
		if player.animation_player_current_animation() != ANIMATION_STANDING_IDLE:
			_on_animation_finished(player.animation_player_current_animation()) 
			player.animation_player_play(ANIMATION_STANDING_IDLE)


func _on_animation_finished(animation_name: String) -> void:
	if animation_name == ANIMATION_FISHING_CASTING:
		player.is_casting_fishing = false
	elif animation_name == ANIMATION_FISHING_REELING:
		player.is_reeling_fishing = false
	elif animation_name == ANIMATION_KICKING_LEFT:
		player.is_kicking_left = false
	elif animation_name == ANIMATION_KICKING_RIGHT:
		player.is_kicking_right = false
	elif animation_name == ANIMATION_RIFLE_FIRING:
		player.is_firing_rifle = false
	elif animation_name == ANIMATION_PUNCHING_LEFT:
		player.is_punching_left = false
	elif animation_name == ANIMATION_PUNCHING_RIGHT:
		player.is_punching_right = false
	elif animation_name == ANIMATION_SWINGING_1H_LEFT:
		player.is_swinging_1h_left = false
	elif animation_name == ANIMATION_SWINGING_1H_RIGHT:
		player.is_swinging_1h_right = false
	elif animation_name == ANIMATION_SWINGING_2H:
		player.is_swinging_2h = false
	elif animation_name == ANIMATION_THROWING_LEFT:
		player.is_throwing_left = false
	elif animation_name == ANIMATION_THROWING_RIGHT:
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
