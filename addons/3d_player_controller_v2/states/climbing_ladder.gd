extends BaseState
class_name ClimbingLadder
## 🪜 Climbing ladders.

# Climbing Ladder 🔵 Mixamo animations
const MIX_ANIMATION_CLIMBING_LADDER := "Climbing_Ladder/mixamo_com"
# Climbing Ladder 🟣 Quaternius animations
const QUAT_ANIMATION_CLIMBING_LADDER := MIX_ANIMATION_CLIMBING_LADDER # There is no Quaternius animation yet (UAl1/UAL2)

const NODE_STATE := States.State.CLIMBING_LADDER


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓑ/[shift] _pressed_ -> Start "sprinting"
	if player.enable_sprinting:
		if event.is_action_pressed(Controls.BUTTON_1):
			player.speed_current = player.speed_climbing * 2
		elif event.is_action_released(Controls.BUTTON_1):
			player.speed_current = player.speed_climbing

	# Ⓨ/[Ctrl] _pressed_ -> Start "falling"
	if event.is_action_pressed(Controls.BUTTON_3):
		transition_state(NODE_STATE, States.State.FALLING)
		return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Check the eye-line for a ledge to grab -> Move to "jump target" (like mantling)
	if not player.ray_cast_top.is_colliding() \
	and player.ray_cast_high.is_colliding() \
	and player.shape_cast_jump_target.is_colliding():
		player.global_position = player.shape_cast_jump_target.get_collision_point(0)
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Move the player while climbing
	player.move_player()

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# 🐢🐇 Set animation playback speed based on [Climbing] speed
	var speed_scale = 1.5 if player.speed_current > player.speed_climbing else 1.0
	player.animation_player_set_speed_scale(speed_scale)

	var animation = MIX_ANIMATION_CLIMBING_LADDER if player.animation_set == 0 else QUAT_ANIMATION_CLIMBING_LADDER
	var current_animation = player.animation_player_current_animation()

	# ↑ "climbing ladder" up
	if player.input_direction.y < 0:
		if current_animation != animation:
			player.animation_player_play(animation)
	# ↓ "climbing ladder" down
	elif player.input_direction.y > 0:
		if current_animation != animation:
			player.animation_player_play_backwards(animation)
	# "climbing ladder" idle
	else:
		if current_animation == animation:
			player.animation_player_play(animation, 0.0)
		player.animation_player_pause()


## Start "climbing ladder".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.CLIMBING_LADDER

	# Flag the player as "climbing ladder"
	player.is_climbing_ladder = true

	# Set the player's speed
	player.speed_current = player.speed_climbing

	# Reset velocity and virtual velocity
	player.velocity = Vector3.ZERO
	player.virtual_velocity = Vector3.ZERO

	# Move the player to the ladder
	player.move_to_ladder()

	# Give the player a moment to move to the ladder
	await get_tree().process_frame

	# Begin playing the "climbing ladder" animation (locked) as a transition
	var target_animation = MIX_ANIMATION_CLIMBING_LADDER if player.animation_set == 0 else QUAT_ANIMATION_CLIMBING_LADDER
	player.animation_player_play_locked(target_animation, 0.2)


## Stop "climbing ladder".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "climbing ladder"
	player.is_climbing_ladder = false

	# Reset animation playback speed
	player.animation_player_set_speed_scale(1.0)
