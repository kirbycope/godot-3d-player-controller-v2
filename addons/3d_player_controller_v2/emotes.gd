extends CanvasLayer

@onready var d_pad = $DPad
@onready var keyboard = $Keyboard
@onready var player = get_parent()


func _process(delta):
	# Do nothing if emotes are not enabled
	if not player.enable_emotes: return

	# Do nothing if paused
	if player.pause.visible:
		hide()
		return

	if not visible:
		# (DPad-Down)/[B] _pressed_ -> Show emotes
		if Input.is_action_just_pressed(player.controls.button_14):
			show()
	else:
		# (DPad-Up)/[Tab] _pressed_ -> Emote __
		if Input.is_action_just_pressed(player.controls.button_12):
			player.play_locked_animation("Standing_Clapping/mixamo_com")
			hide()
		# (DPad-Down)/[Q] _pressed_ -> Emote __
		elif Input.is_action_just_pressed(player.controls.button_13):
			player.play_locked_animation("Standing_Crying/mixamo_com")
			hide()
		# (DPad-Down)/[B] _pressed_ -> Emote __
		elif Input.is_action_just_pressed(player.controls.button_14):
			player.play_locked_animation("Standing_Waving/mixamo_com")
			hide()
		# (DPad-Right)/[T] _pressed_ -> Emote __
		elif Input.is_action_just_pressed(player.controls.button_15):
			player.play_locked_animation("Standing_Quick_Informal_Bow/mixamo_com")
			hide()
		# (Start)/[Esc] _pressed_ -> Hide emotes
		elif Input.is_action_just_pressed(player.controls.button_9):
			hide()

	if visible:
		# Display appropriate controls
		$DPad.visible = (player.controls.last_input_type == player.controls.InputType.CONTROLLER)
		$Keyboard.visible = (player.controls.last_input_type == player.controls.InputType.KEYBOARD_MOUSE)
