extends BaseState

const ANIMATION_CASTING := "Fishing_Cast/mixamo_com"
const ANIMATION_FISHING := "Fishing_Idle/mixamo_com"
const ANIMATION_REELING := "Fishing_Reel/mixamo_com"
const ANIMATION_STANDING := "AnimationLibrary_Godot/Idle"
const NODE_NAME := "Standing"
const NODE_STATE := States.State.STANDING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Ⓨ/[Ctrl] _pressed_ -> Start "crouching"
	if player.enable_crouching:
		if Input.is_action_pressed(player.controls.button_3) \
		and player.is_on_floor():
			transition_state(NODE_STATE, States.State.CROUCHING)
			return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	if player.is_fishing:
		# 🄻1/[MB0] _pressed_ -> Start "casting"
		if Input.is_action_pressed(player.controls.button_4):
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_CASTING:
				# Play the "casting" animation
				player.animation_player.play(ANIMATION_CASTING)

		# 🅁1/[MB1] _pressed_ -> Start "reeling"
		elif Input.is_action_pressed(player.controls.button_5):
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_REELING:
				# Play the "reeling" animation
				player.animation_player.play(ANIMATION_REELING)

		# Must be fishing (but not casting or reeling) -> Play "fishing" animation
		else:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_FISHING:
				# Play the "fishing" animation
				player.animation_player.play(ANIMATION_FISHING)

	# Must not be fishing -> Play "standing" animation
	else:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_STANDING:
			# Play the "standing" animation
			player.animation_player.play(ANIMATION_STANDING)



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
