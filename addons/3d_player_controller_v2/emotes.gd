extends CanvasLayer
## Manages emote selection UI with controller and keyboard input for triggering player animations


@onready var d_pad = $DPad
@onready var keyboard = $Keyboard
@onready var player = get_parent()


func _ready() -> void:
	hide()


func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if emotes are not enabled
	if not player.enable_emotes: return

	# Do nothing if chat input is active
	if player.chat.line_edit.visible: return

	# Do nothing if paused
	if player.pause.visible:
		hide()
		return

	if not visible:
		# (DPad-Down)/[B] _released_ -> Show emotes
		if Input.is_action_just_released(Controls.BUTTON_14):
			show()
	else:
		# (DPad-Up)/[Tab] _released_ -> Emote __
		if Input.is_action_just_released(Controls.BUTTON_12):
			player.animation_player_play_locked("Standing_Clapping/mixamo_com")
			hide()
		# (DPad-Down)/[Q] _released_ -> Emote __
		elif Input.is_action_just_released(Controls.BUTTON_13):
			player.animation_player_play_locked("Standing_Crying/mixamo_com")
			hide()
		# (DPad-Down)/[B] _released_ -> Emote __
		elif Input.is_action_just_released(Controls.BUTTON_14):
			player.animation_player_play_locked("Standing_Waving/mixamo_com")
			hide()
		# (DPad-Right)/[T] _released_ -> Emote __
		elif Input.is_action_just_released(Controls.BUTTON_15):
			player.animation_player_play_locked("Standing_Quick_Informal_Bow/mixamo_com")
			hide()
		# (Start)/[Esc] _pressed_ -> Hide emotes
		elif Input.is_action_just_pressed(Controls.BUTTON_9):
			hide()

	if visible:
		# Display appropriate controls
		$DPad.visible = (player.controls.last_input_type == Controls.InputType.CONTROLLER)
		$Keyboard.visible = (player.controls.last_input_type == Controls.InputType.KEYBOARD_MOUSE)
