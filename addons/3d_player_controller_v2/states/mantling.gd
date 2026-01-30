extends BaseState
class_name Mantling
## 🧗 Mantling on top of ledges (braced) and bars (not braced).

# Mantling 🔵 Mixamo animations
const MIX_ANIMATION_MANTLING_BRACED := "Hanging_Braced_To_Crouch/mixamo_com"
const MIX_ANIMATION_MANTLING_HANGING := "Hanging_Climb_To_Standing/mixamo_com"
# Mantling 🟣 Quaternius animations
const QUAT_ANIMATION_MANTLING_BRACED := "AnimationLibrary_Godot/ClimbLedge"
const QUAT_ANIMATION_MANTLING_HANGING := "AnimationLibrary_Godot/ClimbLedge"

const NODE_STATE := States.State.MANTLING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the player's hang is braced (the collider has somewhere for the player's footing)
	var is_braced = player.ray_cast_low.is_colliding()
	var mix_anim = MIX_ANIMATION_MANTLING_BRACED if is_braced else MIX_ANIMATION_MANTLING_HANGING
	var quat_anim = QUAT_ANIMATION_MANTLING_BRACED if is_braced else QUAT_ANIMATION_MANTLING_HANGING
	var anim = quat_anim if player.animation_set == 1 else mix_anim

	if player.animation_player_current_animation() != anim:
		player.animation_player_play(anim)
		player.animation_player_connect("animation_finished", _on_animation_finished)
		# Tween camera position during animation
		var camera_start_position = player.camera.global_position
		var end_position = player.ray_cast_jump_target.get_collision_point()
		var camera_end_position = camera_start_position + (end_position - player.global_position)
		var tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(
			player.camera,
			"global_position",
			camera_end_position,
			player.animation_player_current_animation_length()
		)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name in [
		MIX_ANIMATION_MANTLING_BRACED,
		MIX_ANIMATION_MANTLING_HANGING,
		QUAT_ANIMATION_MANTLING_BRACED,
		QUAT_ANIMATION_MANTLING_HANGING
	]:
		if player.animation_player_is_connected("animation_finished", _on_animation_finished):
			player.animation_player_disconnect("animation_finished", _on_animation_finished)
		player.animation_player_play("Standing/mixamo_com", 0.0, 1.0, false)
		player.global_position = player.ray_cast_jump_target.get_collision_point()
		transition_state(NODE_STATE, States.State.STANDING)


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
