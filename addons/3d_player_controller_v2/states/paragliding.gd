extends BaseState

const ANIMATION_PARAGLIDING := "Hanging/mixamo_com"
const NODE_NAME := "Paragliding"
const NODE_STATE := States.State.PARAGLIDING

var paraglider


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓨ/[Ctrl] _pressed_ -> Start "falling"
	if event.is_action_pressed(player.controls.button_3):
		transition_state(NODE_STATE, States.State.FALLING)
		return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if the player is on the ground -> Start "standing"
	if player.is_on_floor():
		# Start "standing"
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_PARAGLIDING:
		# Play the "paragliding" animation
		player.animation_player.play(ANIMATION_PARAGLIDING)


## Start "paragliding".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.PARAGLIDING

	# Flag the player as "paragliding"
	player.is_paragliding = true

	# Set the player's speed
	player.speed_current = player.speed_paragliding

	# Stop positive vertical velocity (according to player.up_direction)
	var vertical_speed = player.velocity.dot(player.up_direction)
	if vertical_speed > 0:
		player.velocity -= player.up_direction * vertical_speed

	# Set the player's gravity
	player.gravity = 3.0

	# Spawn the paraglider
	paraglider = load("uid://crkvmowfmaa1r").instantiate()
	player.visuals.add_child(paraglider)
	paraglider.position = Vector3(0, 1.8, 0)  # Adjust position as needed
	paraglider.rotation = Vector3(0, deg_to_rad(180), 0)  # Adjust rotation as needed


## Stop "paragliding".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "paragliding"
	player.is_paragliding = false

	# [Re]Set the player's gravity
	player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

	# Remove the paraglider
	paraglider.queue_free()
