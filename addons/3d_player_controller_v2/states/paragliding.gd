extends BaseState
class_name Paragliding
## 🪂 Paragliding through the air.

# Paragliding 🔵 Mixamo animations
const MIX_ANIMATION_PARAGLIDING := "Hanging/mixamo_com"
var SFX_PARAGLIDING = preload("res://addons/3d_player_controller_v2/assets/sounds/651541__nsstudios__wind-draft-loop-1.wav")

const NODE_STATE := States.State.PARAGLIDING

@export var paraglider_gravity := 2.0 ## Reduced gravity value while paragliding.

var paraglider


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Ⓨ/[Ctrl] _pressed_ -> Start "falling"
	if event.is_action_pressed(Controls.BUTTON_3):
		transition_state(NODE_STATE, States.State.FALLING)
		return


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Check if the player is on the ground -> Start "standing"
	if player.is_on_floor():
		# Start "standing"
		transition_state(NODE_STATE, States.State.STANDING)
		return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	var animation = MIX_ANIMATION_PARAGLIDING
	var current_animation = player.animation_player_current_animation()
	if current_animation != animation:
		player.animation_player_play(animation)
		player.audio_stream_player_sfx.stream = SFX_PARAGLIDING
		player.audio_stream_player_sfx.play()


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
	player.gravity = paraglider_gravity

	# Spawn the paraglider
	var paraglider_scene = load("res://scenes/props/paraglider.tscn")
	if paraglider_scene:
		paraglider = paraglider_scene.instantiate()
		player.visuals.add_child(paraglider)


## Stop "paragliding".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "paragliding"
	player.is_paragliding = false

	# [Re]Set the player's gravity
	player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

	# Remove the paraglider
	if paraglider:
		paraglider.queue_free()

	# Stop the paragliding SFX
	if player.audio_stream_player_sfx.stream == SFX_PARAGLIDING:
		player.audio_stream_player_sfx.stop()
