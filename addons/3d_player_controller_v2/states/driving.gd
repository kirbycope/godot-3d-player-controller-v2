extends BaseState
class_name Driving
## 🚗 Driving a vehicle.

# Driving 🔵 Mixamo animations
const MIX_ANIMATION_DRIVING := "Driving/mixamo_com"
# Driving 🟣 Quaternius animations
const QUAT_ANIMATION_DRIVING := "UAL1/Driving"

const NODE_STATE := States.State.DRIVING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓨ/[Ctrl] _pressed_ -> Exit vehicle
	if player.is_driving:
		if event.is_action_pressed(Controls.BUTTON_3):
			transition_state(player.current_state, States.State.STANDING)
			return
		else:
			return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	var animation = QUAT_ANIMATION_DRIVING if player.animation_set == 1 else MIX_ANIMATION_DRIVING
	var current_animation = player.animation_player_current_animation()
	if current_animation != animation:
		player.animation_player_play(animation)


## Start "driving".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.DRIVING

	# Flag the player as "driving"
	player.is_driving = true

	# Disable the player's collision shape to prevent clipping with the vehicle
	player.collision_shape.disabled = true


## Stop "driving".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "driving"
	player.is_driving = false

	# [Re]Enable the player's collision shape
	player.collision_shape.disabled = false

	# Reset the camera yaw offset so it returns behind the player after exiting the vehicle
	# (camera free-look while driving may have left an offset on the camera mount)
	if is_instance_valid(player) and is_instance_valid(player.camera_mount):
		player.camera_mount.rotation.y = 0.0
