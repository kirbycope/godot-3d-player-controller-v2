extends BaseState
class_name Hanging
## 🐒 Hanging from ledges (braced) or bars (not braced).

# Hanging 🔵 Mixamo animations
const MIX_ANIMATION_HANGING := "Hanging/mixamo_com"
const MIX_ANIMATION_HANGING_SHIMMY_LEFT := "Hanging_Shimmy_Left/mixamo_com"
const MIX_ANIMATION_HANGING_SHIMMY_RIGHT := "Hanging_Shimmy_Right/mixamo_com"
const MIX_ANIMATION_HANGING_BRACED := "Hanging_Braced/mixamo_com"
const MIX_ANIMATION_HANGING_BRACED_SHIMMY_LEFT := "Hanging_Braced_Shimmy_Left/mixamo_com"
const MIX_ANIMATION_HANGING_BRACED_SHIMMY_RIGHT := "Hanging_Braced_Shimmy_Right/mixamo_com"

const NODE_STATE := States.State.HANGING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "mantling"
	if event.is_action_pressed(Controls.BUTTON_0):
		if player.shape_cast_jump_target.is_colliding():
			if player.enable_mantling:
				transition_state(NODE_STATE, States.State.MANTLING)
				return
			else:
				# Tween player position to target
				var end_position = player.shape_cast_jump_target.get_collision_point(0)
				# Adjust down by player height since collision point is at head level
				end_position.y -= player.collision_height
				var tween = get_tree().create_tween()
				tween.set_trans(Tween.TRANS_LINEAR)
				tween.tween_property(
					player,
					"global_position",
					end_position,
					0.2
				)
				tween.tween_callback(func(): transition_state(NODE_STATE, States.State.STANDING))

	# Ⓨ/[Ctrl] _pressed_ -> Start "falling"
	if event.is_action_pressed(Controls.BUTTON_3):
		transition_state(NODE_STATE, States.State.FALLING)
		return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Check if the player has no raycast collision -> Start "falling"
	if not player.ray_cast_top.is_colliding() and not player.ray_cast_high.is_colliding():
		# Start falling
		transition_state(NODE_STATE, States.State.FALLING)

	# Check if the player is on the ground -> Start "standing"
	if player.is_on_floor() and abs(player.velocity).length() < 0.2:
		# Start "standing"
		transition_state(NODE_STATE, States.State.STANDING)

	# Ⓑ/[shift] _pressed_ -> Move faster while "hanging"
	if player.enable_sprinting:
		if Input.is_action_pressed(Controls.BUTTON_1):
			player.speed_current = player.speed_hanging * 2
		else:
			player.speed_current = player.speed_hanging

	# Move the player while hanging
	player.move_player()

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# 🐢🐇 Set animation playback speed based on [Hanging] speed
	if player.speed_current > player.speed_hanging:
		player.animation_player_set_speed_scale(1.5)
	else:
		player.animation_player_set_speed_scale(1.0)

	# Check if the player's hang is braced (the collider has somewhere for the player's footing)
	var is_braced = player.ray_cast_low.is_colliding()

	var mixamo_animation: String
	# "shimmy" left ←
	if Input.is_action_pressed(Controls.MOVE_LEFT):
		mixamo_animation = MIX_ANIMATION_HANGING_BRACED_SHIMMY_LEFT if is_braced else MIX_ANIMATION_HANGING_SHIMMY_LEFT
	# "shimmy" right →
	elif Input.is_action_pressed(Controls.MOVE_RIGHT):
		mixamo_animation = MIX_ANIMATION_HANGING_BRACED_SHIMMY_RIGHT if is_braced else MIX_ANIMATION_HANGING_SHIMMY_RIGHT
	# "hanging" idle
	else:
		mixamo_animation = MIX_ANIMATION_HANGING_BRACED if is_braced else MIX_ANIMATION_HANGING

	var animation = mixamo_animation
	player.animation_player_play(animation)


## Start "hanging".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.HANGING

	# Flag the player as "hanging"
	player.is_hanging = true

	# Set the player's speed
	player.speed_current = player.speed_hanging

	# Reset velocity and virtual velocity
	player.velocity = Vector3.ZERO
	player.virtual_velocity = Vector3.ZERO

	# Move the player to the wall
	player.move_to_wall()


## Stop "hanging".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "hanging"
	player.is_hanging = false

	# Reset animation playback speed
	player.animation_player_set_speed_scale(1.0)
