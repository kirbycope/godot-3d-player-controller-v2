extends BaseState
class_name Mantling
## 🧗 Mantling on top of ledges (braced) and bars (not braced).

# Mantling 🔵 Mixamo animations
const MIX_ANIMATION_MANTLING_BRACED := "Hanging_Braced_To_Crouch/mixamo_com"
const MIX_ANIMATION_MANTLING_HANGING := "Hanging_Climb_To_Standing/mixamo_com"

const NODE_STATE := States.State.MANTLING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	var current_animation = player.animation_player_current_animation()
	var target_animation: String

	# Check if the player's hang is braced (the collider has somewhere for the player's footing)
	var is_braced = player.ray_cast_low.is_colliding()
	target_animation = MIX_ANIMATION_MANTLING_BRACED if is_braced else MIX_ANIMATION_MANTLING_HANGING

	if current_animation != target_animation:
		player.animation_player_play(target_animation)
		player.animation_player_connect("animation_finished", _on_animation_finished)
		# Tween camera position during animation
		var camera_start_position = player.camera.global_position
		var end_position = player.shape_cast_jump_target.get_collision_point()
		var camera_end_position = camera_start_position + (end_position - player.global_position)
		var tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(
			player.camera,
			"global_position",
			camera_end_position,
			player.animation_player_current_animation_length(target_animation)
		)


func _on_animation_finished(anim_name: String) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	if anim_name in [
		MIX_ANIMATION_MANTLING_BRACED,
		MIX_ANIMATION_MANTLING_HANGING
	]:
		if player.animation_player_is_connected("animation_finished", _on_animation_finished):
			player.animation_player_disconnect("animation_finished", _on_animation_finished)
		player.animation_player_play("Standing/mixamo_com", 0.0, 1.0, false)
		player.global_position = player.shape_cast_jump_target.get_collision_point()
		transition_state(NODE_STATE, States.State.STANDING)
		return


## Start "mantling".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.MANTLING

	# Flag the player as "mantling"
	player.is_mantling = true


## Stop "mantling".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "mantling"
	player.is_mantling = false
