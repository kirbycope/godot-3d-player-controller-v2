extends TextureProgressBar
## Stamina UI logic for climbing and sprinting.

var is_exhausted := false
var stamina_current := 100.0
var stamina_drain_rate := 20.0
var stamina_regen_rate := 15.0

@onready var timer_hide: Timer = $TimerHide
@onready var player: CharacterBody3D = $"../../../Player"


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Check if the player is" exhausted"
	if is_exhausted:
		# Check if the player has had time to recover
		if timer_hide.is_stopped():
			# Flag the player as no longer "exhausted"
			is_exhausted = false
			# Enable_sprinting
			player.enable_sprinting = true

	# The player must not be "exhausted"
	else:
		# Check if player is sprinting (on ground) or fast climbing
		var is_fast_climbing = player.is_climbing and Input.is_action_pressed(player.controls.button_1)
		# Check if player is climbing and actively moving via input (not just physics-induced velocity)
		var has_movement_input = Input.is_action_pressed(player.controls.move_left) or Input.is_action_pressed(player.controls.move_right) or Input.is_action_pressed(player.controls.move_up) or Input.is_action_pressed(player.controls.move_down)
		var is_climbing_and_moving = player.is_climbing and has_movement_input
		var is_draining_stamina = player.is_sprinting or is_fast_climbing or is_climbing_and_moving
		
		# Update stamina based on player state
		if is_draining_stamina:
			show()
			# Use different drain rates: fast climbing drains more, regular climbing drains less
			if is_fast_climbing:
				stamina_current -= stamina_drain_rate * _delta
			elif is_climbing_and_moving:
				stamina_current -= (stamina_drain_rate * 0.5) * _delta  # Half rate for normal climbing
			else:
				stamina_current -= stamina_drain_rate * _delta  # Full rate for sprinting
		elif !player.is_climbing and !player.is_swimming:
			# Only regenerate stamina if not climbing or swimming
			stamina_current += stamina_regen_rate * _delta

		# Clamp stamina between 0 and 100
		stamina_current = clamp(stamina_current, min_value, max_value)

		# Update the progress bar value
		value = stamina_current

		# Check if stamina is full
		if stamina_current == max_value and timer_hide.is_stopped():
			# Start the hide progress bar timer
			timer_hide.start()

		# Check if stamina is empty and not flagged as "exhausted"
		if stamina_current == min_value and !is_exhausted:
			# Flag the player as "exhausted"
			is_exhausted = true
			# Disable sprinting
			player.enable_sprinting = false
			# If climbing, reduce speed to normal climbing speed
			if player.is_climbing:
				player.speed_current = player.speed_climbing
			# Start the hide progress bar timer
			timer_hide.start()
			if player.is_on_floor():
				player.play_locked_animation("Standing_Breathing_Heavy/mixamo_com")

		# Check if the game is paused
		if player.pause.is_visible():
			hide()

		# The game must not be paused
		else:
			if stamina_current < max_value:
				show()


func _on_timer_hide_timeout() -> void:
	hide()
