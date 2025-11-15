extends BaseState

## Handles vehicle driving: input to exit, animation playback, and collision shape toggling while in a vehicle.

const ANIMATION_DRIVING := "Driving/mixamo_com"
const NODE_NAME := "Driving"
const NODE_STATE := States.State.DRIVING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓨ/[Ctrl] _pressed_ -> Exit vehicle
	if player.is_driving:
		if event.is_action_pressed(player.controls.button_3):
			transition_state(player.current_state, States.State.STANDING)
		else:
			return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_DRIVING:
		player.animation_player.play(ANIMATION_DRIVING)


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
