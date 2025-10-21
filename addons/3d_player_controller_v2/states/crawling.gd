extends BaseState

const ANIMATION_CRAWLING := "AnimationLibrary_Godot/Crawl_Fwd"
const NODE_NAME := "Crawling"
const NODE_STATE := States.State.CRAWLING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if there is no input (but still crouching) -> Start "crouching"
	if player.input_direction == Vector2.ZERO \
	and Input.is_action_pressed(player.controls.button_3):
		transition_state(NODE_STATE, States.State.CROUCHING)
		return
	
	# Ⓐ/[Space] _pressed_ and rolling is enabled -> Start "rolling"
	if player.enable_rolling:
		if Input.is_action_just_pressed(player.controls.button_0):
			transition_state(NODE_STATE, States.State.ROLLING)
			return

	# Ⓨ/[Ctrl] _just_released_ -> Start "standing"
	if Input.is_action_just_released(player.controls.button_3):
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if in first person and moving backwards
	var play_backwards = (player.camera.perspective == player.camera.Perspective.FIRST_PERSON) and Input.is_action_pressed(player.controls.move_down)

	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_CRAWLING:
		# Play the "crawling" animation
		if play_backwards:
			player.animation_player.play_backwards(ANIMATION_CRAWLING)
		else:
			player.animation_player.play(ANIMATION_CRAWLING)


## Start "crawling".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.CRAWLING

	# Flag the player as "crawling"
	player.is_crawling = true

	# Set the player's speed
	player.speed_current = player.speed_crawling

	# Set the player collision shape's height
	#player.collision_shape_3d.shape.height = player.collision_height / 2

	# Set the player collision shape's rotation
	player.collision_shape_3d.rotation.x = deg_to_rad(90)

	# Set the player collision shape's position
	player.collision_shape_3d.position = player.collision_position / 3
	player.collision_shape_3d.position.z += player.collision_height / 3


## Stop "crawling".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "crawling"
	player.is_crawling = false

	# [Re]set the player collision shape's height
	#player.collision_shape_3d.shape.height = player.collision_height

	# [Re]set the player collision shape's rotation
	player.collision_shape_3d.rotation.x = deg_to_rad(0)

	# [Re]set the player collision shape's position
	player.collision_shape_3d.position = player.collision_position
