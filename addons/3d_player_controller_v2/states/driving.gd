extends BaseState

const ANIMATION_DRIVING := "AnimationLibrary_Godot/Driving"
const NODE_NAME := "Driving"
const NODE_STATE := States.State.DRIVING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	player.collision_shape_3d.disabled = true


## Stop "driving".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "driving"
	player.is_driving = false

	# [Re]Enable the player's collision shape
	player.collision_shape_3d.disabled = false
