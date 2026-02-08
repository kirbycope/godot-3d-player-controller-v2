extends BaseState
class_name Skateboarding
## 🛹 Skateboarding on a skateboard.

# Skateboarding 🔵 Mixamo animations
const MIX_ANIMATION_SKATEBOARDING := "Skateboarding/mixamo_com"
const MIX_ANIMATION_SKATEBOARDING_FAST := "Skateboarding_Fast/mixamo_com"
const MIX_ANIMATION_SKATEBOARDING_SLOW := "Skateboarding_Slow/mixamo_com"
# Skateboarding 🟣 Quaternius animations
const QUAT_ANIMATION_SKATEBOARDING := "Skateboarding/mixamo_com" # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_SKATEBOARDING_FAST := "Skateboarding_Fast/mixamo_com" # There is no Quaternius animation yet (UAl1/UAL2)
const QUAT_ANIMATION_SKATEBOARDING_SLOW := "Skateboarding_Slow/mixamo_com" # There is no Quaternius animation yet (UAl1/UAL2)

const NODE_STATE := States.State.SKATEBOARDING


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓐ/[Space] _pressed_ (while grounded) -> Perform "ollie"
	if event.is_action_pressed(Controls.BUTTON_0) and player.is_on_floor():
		# Increase the player's velocity in the up direction
		player.velocity += player.up_direction * player.speed_jumping


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Ⓑ/[shift] _pressed_ -> Move faster while "skateboarding"
	if player.enable_sprinting and not player.pause.visible:
		if Input.is_action_pressed(Controls.BUTTON_1):
			player.speed_current = player.speed_skateboarding * 1.5
		else:
			player.speed_current = player.speed_skateboarding

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	var mixamo_animation: String
	var quaternius_animation: String
	var height_scale := 1.0
	if player.input_direction == Vector2.ZERO:
		mixamo_animation = MIX_ANIMATION_SKATEBOARDING_SLOW
		quaternius_animation = QUAT_ANIMATION_SKATEBOARDING_SLOW
		height_scale = 1.0
	elif player.speed_current == player.speed_skateboarding:
		mixamo_animation = MIX_ANIMATION_SKATEBOARDING
		quaternius_animation = QUAT_ANIMATION_SKATEBOARDING
		height_scale = 0.95
	elif player.speed_current > player.speed_skateboarding:
		mixamo_animation = MIX_ANIMATION_SKATEBOARDING_FAST
		quaternius_animation = QUAT_ANIMATION_SKATEBOARDING_FAST
		height_scale = 0.9

	var animation = quaternius_animation if player.animation_set == 1 else mixamo_animation
	var current_animation = player.animation_player_current_animation()
	if current_animation != animation:
		player.animation_player_play(animation)
		# Set the player collision shape's height
		player.collision_shape.shape.height = player.collision_height * height_scale
		# Set the player collision shape's position
		player.collision_shape.position = player.collision_position * height_scale


## Start "skateboarding".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.SKATEBOARDING

	# Flag the player as "skateboarding"
	player.is_skateboarding = true

	# Set the player's speed
	player.speed_current = player.speed_skateboarding


## Stop "skateboarding".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "skateboarding"
	player.is_skateboarding = false

	# [Re]set the player collision shape's height
	player.collision_shape.shape.height = player.collision_height

	# [Re]set the player collision shape's position
	player.collision_shape.position = player.collision_position
