extends BaseState
class_name Climbing
## 🧗 Climbing a (mostly) vertical surface.

# Climbing 🔵 Mixamo animations
const MIX_ANIMATION_CLIMBING_UP := "Climbing_Up/mixamo_com"
const MIX_ANIMATION_CLIMBING_DOWN := "Climbing_Down/mixamo_com"
const MIX_ANIMATION_CLIMBING_LEFT := "Hanging_Braced_Shimmy_Left/mixamo_com"
const MIX_ANIMATION_CLIMBING_RIGHT := "Hanging_Braced_Shimmy_Right/mixamo_com"
# Climbing 🟣 Quaternius animations
const QUAT_ANIMATION_CLIMBING_UP := "UAL1/Climb_Up"
const QUAT_ANIMATION_CLIMBING_DOWN := "UAL1/Climb_Down"
const QUAT_ANIMATION_CLIMBING_LEFT := "UAL1/Climb_Left"
const QUAT_ANIMATION_CLIMBING_RIGHT := "UAL1/Climb_Right"

const NODE_STATE := States.State.CLIMBING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓑ/[shift] _pressed_ -> Move faster while "climbing"
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
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Check if the player has no raycast collision -> Start "falling"
	if not player.ray_cast_top.is_colliding() \
	and not player.ray_cast_high.is_colliding():
		transition_state(NODE_STATE, States.State.FALLING)
		return

	# Check the eye-line for a ledge to grab -> Start "hanging"
	if player.enable_hanging:
		if not player.ray_cast_top.is_colliding() \
		and player.ray_cast_high.is_colliding():
			var collision_object = player.ray_cast_high.get_collider()
			if not collision_object is CharacterBody3D \
			and not collision_object is SoftBody3D:
				transition_state(NODE_STATE, States.State.HANGING)
				return

	# Move the player while climbing
	player.move_player()

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Set animation playback speed based on climbing speed
	if player.speed_current > player.speed_climbing:
		player.animation_player_set_speed_scale(1.5)
	else:
		player.animation_player_set_speed_scale(1.0)

	var mix_anim: String
	var quat_anim: String

	# "climbing" left ←
	if player.input_direction.x < 0:
		mix_anim = MIX_ANIMATION_CLIMBING_LEFT
		quat_anim = QUAT_ANIMATION_CLIMBING_LEFT
	# "climbing" right →
	elif player.input_direction.x > 0:
		mix_anim = MIX_ANIMATION_CLIMBING_RIGHT
		quat_anim = QUAT_ANIMATION_CLIMBING_RIGHT
	else: # Left/Right animations have priority over Up/Down, so if left/right is not pressed, then process up/down input
		# "climbing" up ↑
		if player.input_direction.y < 0:
			mix_anim = MIX_ANIMATION_CLIMBING_UP
			quat_anim = QUAT_ANIMATION_CLIMBING_UP
		# "climbing" down ↓
		elif player.input_direction.y > 0:
			mix_anim = MIX_ANIMATION_CLIMBING_DOWN
			quat_anim = QUAT_ANIMATION_CLIMBING_DOWN
		# "climbing" idle
		else:
			player.animation_player_pause()
			return

	if player.animation_set == 0:
		if player.animation_player_current_animation() != mix_anim:
			player.animation_player_play(mix_anim)
	elif player.animation_set == 1:
		if player.animation_player_current_animation() != quat_anim:
			player.animation_player_play(quat_anim)


## Start "climbing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.CLIMBING

	# Flag the player as "climbing"
	player.is_climbing = true

	# Set the player's speed
	player.speed_current = player.speed_climbing

	# Reset velocity and virtual velocity
	player.velocity = Vector3.ZERO
	player.virtual_velocity = Vector3.ZERO

	# Move the player to the wall
	player.move_to_wall()

	# Give the player a moment to move to the wall
	await get_tree().process_frame

	# Begin playing the "climbing" animation (locked) as a transition
	var target_animation := ""
	# 🔵 Mixamo
	if player.animation_set == 0:
		target_animation = MIX_ANIMATION_CLIMBING_UP
	# 🟣 Quaternius
	elif player.animation_set == 1:
		target_animation = QUAT_ANIMATION_CLIMBING_UP
	player.animation_player_play_locked(target_animation, 0.2)


## Stop "climbing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "climbing"
	player.is_climbing = false

	# Reset animation playback speed
	player.animation_player_set_speed_scale(1.0)
