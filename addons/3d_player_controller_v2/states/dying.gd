extends BaseState
class_name Dying
## 💀 Playing the "dying" animation and handling player death logic.

# Dying 🔵 Mixamo animations
const MIX_ANIMATION_DYING := "Dying/mixamo_com" # (laying down)
const MIX_ANIMATION_DYING_BACKWARDS := "Dying_Backwards/mixamo_com" # (falling down)
# Dying 🔵 Mixamo animations (holding equipment)
const MIX_ANIMATION_DYING_BACKWARDS_HOLDING_1H_LEFT := "Dying_Backwards_1H_Left/mixamo_com"
const MIX_ANIMATION_DYING_BACKWARDS_HOLDING_1H_RIGHT := "Dying_Backwards_1H_Right/mixamo_com"
const MIX_ANIMATION_DYING_BACKWARDS_HOLDING_2H := "Dying_Backwards_2H/mixamo_com"
# Dying 🔵 Mixamo animations (holding rifle)
const MIX_ANIMATION_DYING_BACKWARDS_HOLDING_RIFLE := "Dying_Backwards_Rifle/mixamo_com"
# Dying 🔵 Mixamo animations (sword and shield)
const MIX_ANIMATION_DYING_BACKWARDS_SWORD_AND_SHIELD := "Dying_Backwards_Sword_and_Shield/mixamo_com"

const NODE_STATE := States.State.DYING

var dying_yet := false ## False = DYING_BACKWARD, True if on the ground.

## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# ToDo: Boost/roll longer if  Ⓐ/[Space] is pressed


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Default to the dying (laying down) animation
	var animation = MIX_ANIMATION_DYING
	# Play the "dying" animation only once when the player first enters the "dying" state
	if not dying_yet:
		dying_yet = true
		if player.is_holding_1h_left:
			animation = MIX_ANIMATION_DYING_BACKWARDS_HOLDING_1H_LEFT
		elif player.is_holding_1h_right:
			animation = MIX_ANIMATION_DYING_BACKWARDS_HOLDING_1H_RIGHT
		elif player.is_holding_2h:
			animation = MIX_ANIMATION_DYING_BACKWARDS_HOLDING_2H
		elif player.is_holding_rifle:
			animation = MIX_ANIMATION_DYING_BACKWARDS_HOLDING_RIFLE
		elif player.is_holding_shield_1h_left:
			animation = MIX_ANIMATION_DYING_BACKWARDS_SWORD_AND_SHIELD
		else:
			animation = MIX_ANIMATION_DYING_BACKWARDS
		player.animation_player_play_locked(animation)
		if player.character.has_method("play_death_sound_effect"):
			player.character.play_death_sound_effect()
	var current_animation = player.animation_player_current_animation()
	if current_animation != animation:
		player.animation_player_play(animation)


## Start "dying".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.DYING

	# Flag the player as "dying"
	player.is_dying = true

	# Stop any currently playing spell or UI SFX
	if player.audio_stream_player_sfx.playing:
		player.audio_stream_player_sfx.stop()


## Stop "dying".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "dying"
	player.is_dying = false
