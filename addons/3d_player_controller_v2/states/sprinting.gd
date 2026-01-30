extends BaseState
## 🏃 Sprinting at high speed.

# Sprinting 🔵 Mixamo animations
const MIX_ANIMATION_SPRINTING := "Sprinting/mixamo_com"
const MIX_ANIMATION_SPRINTING_HOLDING_RIFLE := "Sprinting_Holding_Rifle/mixamo_com"
# Sprinting 🟣 Quaternius animations
const QUAT_ANIMATION_SPRINTING := "AnimationLibrary_Godot/Sprint"
const QUAT_ANIMATION_SPRINTING_HOLDING_RIFLE := "AnimationLibrary_Godot/Sprint_Holding_Rifle" # TODO: Implement
const QUAT_ANIMATION_SPRINTING_START := "AnimationLibrary_Godot/Sprint_Enter" # TODO: Implement
const QUAT_ANIMATION_SPRINTING_STOP := "AnimationLibrary_Godot/Sprint_Exit" # TODO: Implement
const NODE_STATE := States.State.SPRINTING


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

	# Ⓑ/[shift] _released_ -> Start "standing"
	if event.is_action_released(Controls.BUTTON_1):
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Ⓨ/[Ctrl] _pressed_ -> Start "sliding"
	if player.enable_sliding:
		if event.is_action_pressed(Controls.BUTTON_3) \
		and player.is_on_floor():
			transition_state(NODE_STATE, States.State.SLIDING)
			return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

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
	# Check if in first person and moving backwards
	var play_backwards = (player.camera.perspective == player.camera.Perspective.FIRST_PERSON) and Input.is_action_pressed(Controls.MOVE_DOWN)
	var mix_anim = MIX_ANIMATION_SPRINTING_HOLDING_RIFLE if player.is_holding_rifle else MIX_ANIMATION_SPRINTING
	var quat_anim = QUAT_ANIMATION_SPRINTING_HOLDING_RIFLE if player.is_holding_rifle else QUAT_ANIMATION_SPRINTING

	if player.animation_set == 0:
		if player.animation_player_current_animation() != mix_anim:
			if play_backwards:
				player.animation_player_play_backwards(mix_anim)
			else:
				player.animation_player_play(mix_anim)
	elif player.animation_set == 1:
		if player.animation_player_current_animation() != quat_anim:
			if play_backwards:
				player.animation_player_play_backwards(quat_anim)
			else:
				player.animation_player_play(quat_anim)


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

	# 🔇 Stop "sprinting" sound effect
	if player.character.has_method("stop_sprint_sound_effect"):
		player.character.stop_sprint_sound_effect()
