extends BaseState

const ANIMATION_FISHING_CASTING := "Fishing_Cast/mixamo_com"
const ANIMATION_FISHING_IDLE := "Fishing_Idle/mixamo_com"
const ANIMATION_FISHING_REELING := "Fishing_Reel/mixamo_com"
const ANIMATION_KICKING_LEFT := "AnimationLibrary_Godot/Kick"
const ANIMATION_KICKING_RIGHT := "AnimationLibrary_Godot/Kick"
const ANIMATION_PUNCHING_LEFT := "AnimationLibrary_Godot/Punch_Jab"
const ANIMATION_PUNCHING_RIGHT := "AnimationLibrary_Godot/Punch_Cross"
const ANIMATION_RIFLE_AIMING := "Rifle_Aiming_Idle/mixamo_com"
const ANIMATION_RIFLE_FIRING := "Rifle_Firing/mixamo_com"
const ANIMATION_RIFLE_IDLE := "Rifle_Idle/mixamo_com"
const ANIMATION_STANDING_IDLE := "AnimationLibrary_Godot/Idle"
const ANIMATION_SWINGING_1H_LEFT := "Standing_Melee_Attack_Downward_Left/mixamo_com"
const ANIMATION_SWINGING_1H_RIGHT := "Standing_Melee_Attack_Downward_Right/mixamo_com"
const NODE_NAME := "Standing"
const NODE_STATE := States.State.STANDING


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓑ/[shift] _pressed_ -> Start "sprinting"
	if event.is_action_pressed(player.controls.button_1):
		if player.enable_sprinting \
		and not player.is_sprinting \
		and player.input_direction != Vector2.ZERO \
		and player.is_on_floor():
			transition_state(NODE_STATE, States.State.SPRINTING)
			return

	# Ⓨ/[Ctrl] _pressed_ -> Start "crouching"
	if event.is_action_pressed(player.controls.button_3):
		if player.enable_crouching \
		and player.is_on_floor():
			transition_state(NODE_STATE, States.State.CROUCHING)
			return

	# 🄻1/[MB0] _pressed_
	if event.is_action_pressed(player.controls.button_4):
		# Fishing "casting"
		if player.is_holding_fishing_rod \
		and not player.is_reeling_fishing:
			player.is_casting_fishing = true
		# Rifle "firing"
		elif player.is_holding_rifle:
			player.is_firing_rifle = true
		# Left 1H "swinging"
		elif player.is_holding_1h_left \
		and not player.is_swinging_1h_right:
			player.is_swinging_1h_left = true
		# Left "punching"
		elif player.enable_punching \
		and not player.is_punching_right:
			player.is_punching_left = true

	# 🄻2/[MB3] _pressed_
	if event.is_action_pressed(player.controls.button_6):
		# Left "kicking"
		if player.enable_kicking:
			player.is_kicking_left = true

	# 🅁1/[MB1] _pressed_ 
	if event.is_action_pressed(player.controls.button_5):
		# Fishing "reeling"
		if player.is_holding_fishing_rod \
		and not player.is_casting_fishing:
			player.is_reeling_fishing = true
		# Rifle "aiming"
		elif player.is_holding_rifle:
			player.is_aiming_rifle = true
		# Right 1H "swinging"
		elif player.is_holding_1h_right \
		and not player.is_swinging_1h_left:
			player.is_swinging_1h_right = true
		# Right "punching"
		elif player.enable_punching \
		and not player.is_punching_left:
			player.is_punching_right = true

	# 🅁1/[MB1] _released_
	if event.is_action_released(player.controls.button_5):
		# Stop "aiming rifle"
		if player.is_holding_rifle \
		and player.is_aiming_rifle:
			player.is_aiming_rifle = false

	# 🅁2/[MB4] _pressed_
	if event.is_action_pressed(player.controls.button_7):
		# Right "kicking"
		if player.enable_kicking:
			player.is_kicking_right = true


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# -- Fishing animations --
	if player.is_holding_fishing_rod:
		if player.is_casting_fishing:
			if player.animation_player.current_animation != ANIMATION_FISHING_CASTING:
				player.animation_player.play(ANIMATION_FISHING_CASTING)
				player.animation_player.connect("animation_finished", _on_animation_finished)
		elif player.is_reeling_fishing:
			if player.animation_player.current_animation != ANIMATION_FISHING_REELING:
				player.animation_player.play(ANIMATION_FISHING_REELING)
				player.animation_player.connect("animation_finished", _on_animation_finished)
		else:
			if player.animation_player.current_animation != ANIMATION_FISHING_IDLE:
				player.animation_player.play(ANIMATION_FISHING_IDLE)
	
	# -- Rifling animations --
	elif player.is_holding_rifle:
		if player.is_firing_rifle:
			if player.animation_player.current_animation != ANIMATION_RIFLE_FIRING:
				player.animation_player.play(ANIMATION_RIFLE_FIRING)
				player.animation_player.connect("animation_finished", _on_animation_finished)
		elif player.is_aiming_rifle:
			if player.animation_player.current_animation != ANIMATION_RIFLE_AIMING:
				player.animation_player.play(ANIMATION_RIFLE_AIMING)
				player.animation_player.connect("animation_finished", _on_animation_finished)
		else:
			if player.animation_player.current_animation != ANIMATION_RIFLE_IDLE:
				player.animation_player.play(ANIMATION_RIFLE_IDLE)

	# -- Kicking animations --
	elif player.enable_kicking \
	and player.is_kicking_left:
		if player.animation_player.current_animation != ANIMATION_KICKING_LEFT:
			player.animation_player.play(ANIMATION_KICKING_LEFT)
			player.animation_player.connect("animation_finished", _on_animation_finished)
	elif player.enable_kicking \
	and player.is_kicking_right:
		if player.animation_player.current_animation != ANIMATION_KICKING_RIGHT:
			player.animation_player.play(ANIMATION_KICKING_RIGHT)
			player.animation_player.connect("animation_finished", _on_animation_finished)

	# -- 1H Swinging animations --
	elif player.is_holding_1h_left \
	and player.is_swinging_1h_left:
		if player.animation_player.current_animation != ANIMATION_SWINGING_1H_LEFT:
			player.animation_player.play(ANIMATION_SWINGING_1H_LEFT)
			player.animation_player.connect("animation_finished", _on_animation_finished)
	elif player.is_holding_1h_right \
	and player.is_swinging_1h_right:
		if player.animation_player.current_animation != ANIMATION_SWINGING_1H_RIGHT:
			player.animation_player.play(ANIMATION_SWINGING_1H_RIGHT)
			player.animation_player.connect("animation_finished", _on_animation_finished)

	# -- Punching animations --
	elif player.enable_punching \
	and player.is_punching_left:
		if player.animation_player.current_animation != ANIMATION_PUNCHING_LEFT:
			player.animation_player.play(ANIMATION_PUNCHING_LEFT)
			player.animation_player.connect("animation_finished", _on_animation_finished)
	elif player.enable_punching \
	and player.is_punching_right:
		if player.animation_player.current_animation != ANIMATION_PUNCHING_RIGHT:
			player.animation_player.play(ANIMATION_PUNCHING_RIGHT)
			player.animation_player.connect("animation_finished", _on_animation_finished)

	# -- Idle animation --
	else:
		if player.animation_player.current_animation != ANIMATION_STANDING_IDLE:
			player.animation_player.play(ANIMATION_STANDING_IDLE)


func _on_animation_finished(animation_name: String) -> void:
	# Disconnect the signal to avoid multiple connections
	player.animation_player.disconnect("animation_finished", _on_animation_finished)
	if animation_name == ANIMATION_FISHING_CASTING:
		player.is_casting_fishing = false
	elif animation_name == ANIMATION_FISHING_REELING:
		player.is_reeling_fishing = false
	elif animation_name == ANIMATION_KICKING_LEFT:
		player.is_kicking_left = false
	#elif animation_name == ANIMATION_KICKING_RIGHT:
		player.is_kicking_right = false
	elif animation_name == ANIMATION_RIFLE_AIMING:
		player.is_aiming_rifle = false
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


## Stop "standing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "standing"
	player.is_standing = false
