extends BaseState
class_name Sprinting
## 🏃 Sprinting at high speed.

# Sprinting 🔵 Mixamo animations
const MIX_ANIMATION := "Sprinting/mixamo_com"
const MIX_ANIMATION_BACKWARD := "Sprinting_Backward/mixamo_com"
const MIX_ANIMATION_STRAFE_LEFT := Running.MIX_ANIMATION_STRAFE_LEFT
const MIX_ANIMATION_STRAFE_RIGHT := Running.MIX_ANIMATION_STRAFE_RIGHT
# Sprinting 🔵 Mixamo animations (sword and shield)
const MIX_ANIMATION_SWORD_AND_SHIELD := Running.MIX_ANIMATION_SWORD_AND_SHIELD
const MIX_ANIMATION_BACKWARD_SWORD_AND_SHIELD := Running.MIX_ANIMATION_BACKWARD_SWORD_AND_SHIELD
const MIX_ANIMATION_STRAFE_LEFT_SWORD_AND_SHIELD := Running.MIX_ANIMATION_STRAFE_LEFT_SWORD_AND_SHIELD
const MIX_ANIMATION_STRAFE_RIGHT_SWORD_AND_SHIELD := Running.MIX_ANIMATION_STRAFE_RIGHT_SWORD_AND_SHIELD
# Sprinting 🔵 Mixamo animations (holding a rifle)
const MIX_ANIMATION_HOLDING_RIFLE := "Sprinting_Holding_Rifle/mixamo_com"
const MIX_ANIMATION_BACKWARD_HOLDING_RIFLE := Running.MIX_ANIMATION_BACKWARD_HOLDING_RIFLE

const NODE_STATE := States.State.SPRINTING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "jumping"
	if event.is_action_pressed(Controls.BUTTON_0):
		if player.enable_jumping \
		and player.is_on_floor() \
		and not player.chat.line_edit.visible:
			transition_state(player.current_state, States.State.JUMPING)
			return

	# Ⓑ/[shift] _released_ -> Start "standing"
	if event.is_action_released(Controls.BUTTON_1):
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Ⓨ/[Ctrl] _pressed_ -> Start "sliding"
	if player.enable_sliding:
		if event.is_action_pressed(Controls.BUTTON_3) and player.is_on_floor():
			transition_state(NODE_STATE, States.State.SLIDING)
			return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Not on floor -> Start "falling"
	if not player.is_on_floor() \
	and not player.ray_cast_below.is_colliding():
		transition_state(player.current_state, States.State.FALLING)
		return

	# 🏃 Play animation
	play_animation()

	# 🔊 Play sound effect
	if player.character.has_method("play_sprint_sound_effect"):
		player.character.play_sprint_sound_effect()


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

	# Handle "running" (while "strafing")
	if is_strafe_left or is_strafe_right:
		# Strafing+Sprinting animations are just Running animations played at a faster speed
		player.animation_player_set_speed_scale(1.5)
		# Handle "running" (while "strafing" and holding a shield)
		if player.is_holding_sword_and_shield:
			# Handle "running" (while "strafing" left and holding a shield)
			if is_strafe_left:
				mixamo_animation = MIX_ANIMATION_STRAFE_LEFT_SWORD_AND_SHIELD
			# Handle "running" (while "strafing" right and holding a shield)
			elif is_strafe_right:
				mixamo_animation = MIX_ANIMATION_STRAFE_RIGHT_SWORD_AND_SHIELD
		# Handle "running" (while "strafing" and unarmed)
		else:
			# Handle "running" (while "strafing" left and unarmed)
			if is_strafe_left:
				mixamo_animation = MIX_ANIMATION_STRAFE_LEFT
			# Handle "running" (while "strafing" right and unarmed)
			elif is_strafe_right:
				mixamo_animation = MIX_ANIMATION_STRAFE_RIGHT
	# Handle "running" (while backpedaling)
	elif is_backpedaling:
		# Handle "running" (while backpedaling and holding a shield)
		if player.is_holding_sword_and_shield:
			mixamo_animation = MIX_ANIMATION_BACKWARD_SWORD_AND_SHIELD
		# Handle "running" (while backpedaling and unarmed)
		else:
			mixamo_animation = MIX_ANIMATION_BACKWARD
		# [Re]set the animation playback speed
		player.animation_player_set_speed_scale(1.0)
	# Handle "sprinting" (while holding a shield)
	elif player.is_holding_sword_and_shield:
		mixamo_animation = MIX_ANIMATION_SWORD_AND_SHIELD
		# [Re]set the animation playback speed
		player.animation_player_set_speed_scale(1.0)
	# Handle "sprinting" (unarmed)
	else:
		mixamo_animation = MIX_ANIMATION
		# [Re]set the animation playback speed
		player.animation_player_set_speed_scale(1.0)

	var current_animation = player.animation_player_current_animation()
	var animation = mixamo_animation
	if current_animation != animation:
		player.animation_player_play(animation)


#func _on_animation_finished(animation_name: String) -> void:
#	pass


## Start "sprinting".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.SPRINTING

	# Flag the player as "sprinting"
	player.is_sprinting = true

	# Set the player's speed
	player.speed_current = player.speed_sprinting


## Stop "sprinting".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "sprinting"
	player.is_sprinting = false

	# Reset animation playback speed
	player.animation_player_set_speed_scale(1.0)

	# 🔇 Stop "sprinting" sound effect
	if player.character.has_method("stop_sprint_sound_effect"):
		player.character.stop_sprint_sound_effect()
