extends BaseState

const ANIMTION_HANGING := "AnimationLibrary_Godot/Hang_Idle"
const NODE_NAME := "Hanging"
const NODE_STATE := States.State.HANGING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the player's hang is braced (the collider has somewhere for the player's footing)
	var is_braced = player.ray_cast_low.is_colliding()
	# Check if the player is shimmying
	var is_shimmying = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")

	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMTION_HANGING:
		# Play the "hanging" animation
		player.animation_player.current_animation = ANIMTION_HANGING


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


## Stop "hanging".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "hanging"
	player.is_hanging = false

	# Set the camera position
	player.camera.camera_spring_arm.position.y = 0.0
