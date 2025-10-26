extends BaseState

const ANIMATION_SWIMMING := "Swimming/mixamo_com"
const ANIMATION_WADING := "Swimming_Treading_Water/mixamo_com"
const NODE_NAME := "Swimming"
const NODE_STATE := States.State.SWIMMING

# Preserve/override floor snapping while swimming
var prev_floor_snap_length: float = -1.0


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ -> Start "mantling"
	if event.is_action_pressed(player.controls.button_0):
		if player.ray_cast_jump_target.is_colliding():
			player.global_position = player.ray_cast_jump_target.get_collision_point()
			transition_state(NODE_STATE, States.State.STANDING) # TODO: Create a mantling state
			return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Ⓐ/[Space] button currently _pressed_ -> Increase player's vertical position
	if Input.is_action_pressed(player.controls.button_0):
		var current_water_level = player.is_swimming_in.global_position.y + player.is_swimming_in.size.y/2 # The origin of the shape is at its center
		var new_player_position_y = player.position.y + 5 * delta
		var player_shoulder_height = new_player_position_y + (player.collision_height * 0.75)
		if player_shoulder_height < current_water_level:
			player.position.y += 5 * delta

	# Ⓨ/[Ctrl] currently _pressed_ -> Decrease player's vertical position
	if Input.is_action_pressed(player.controls.button_3):
		player.position.y -= 5 * delta

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	if player.input_direction == Vector2.ZERO:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_WADING:
			player.animation_player.play(ANIMATION_WADING)
	else:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_SWIMMING:
			player.animation_player.play(ANIMATION_SWIMMING)


## Start "swimming".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.SWIMMING

	# Flag the player as "swimming"
	player.is_swimming = true

	# Set the player's speed
	player.speed_current = player.speed_swimming

	# Set player gravity to zero
	player.gravity = 0.0

	# Set the player's velocity
	player.velocity = Vector3.ZERO
	player.virtual_velocity = Vector3.ZERO

	# Disable floor snapping so water ascent isn't pinned to ground
	prev_floor_snap_length = player.floor_snap_length
	player.floor_snap_length = 0.0


## Stop "swimming".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "swimming"
	player.is_swimming = false

	# [Re]set player gravity to normal
	player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

	# Restore floor snapping to its previous value
	if prev_floor_snap_length >= 0.0:
		player.floor_snap_length = prev_floor_snap_length
		prev_floor_snap_length = -1.0
