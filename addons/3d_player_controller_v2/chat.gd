extends CanvasLayer

@onready var player: CharacterBody3D = get_parent()
@onready var messages_container: VBoxContainer = $VBoxContainer
@onready var line_edit: LineEdit = $LineEdit
@onready var send_button = $SEND


func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# (☰)/[Esc] _pressed_ -> Hide chat input
	if event.is_action_pressed(player.controls.button_9) \
	and line_edit.visible:
		clear_and_hide_input()

	# (D-Pad Right)/[T] _released_ -> Show chat input
	if event.is_action_released(player.controls.button_15) \
	and not line_edit.visible:
		clear_and_show_input()


func clear_and_hide_input():
	line_edit.clear()
	line_edit.hide()
	send_button.hide()


func clear_and_show_input():
	line_edit.clear()
	line_edit.show()
	line_edit.grab_focus()
	send_button.show()


@rpc("any_peer", "call_local")
func send_message(text: String) -> void:
	# Wrap each message in a panel so we can give it a background
	var message_panel := PanelContainer.new()
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.1, 0.6) # dark gray, semi-transparent
	bg.corner_radius_top_left = 6
	bg.corner_radius_top_right = 6
	bg.corner_radius_bottom_left = 6
	bg.corner_radius_bottom_right = 6
	bg.content_margin_left = 8
	bg.content_margin_right = 8
	bg.content_margin_top = 4
	bg.content_margin_bottom = 4
	message_panel.add_theme_stylebox_override("panel", bg)
	messages_container.add_child(message_panel)

	# Add the actual text message
	var rtl = RichTextLabel.new()
	rtl.text = text
	rtl.custom_minimum_size = Vector2(480, 26)
	message_panel.add_child(rtl)

	# Auto-hide this message after 30 seconds (hide the whole panel)
	var timer := get_tree().create_timer(30.0)
	timer.timeout.connect(func():
		if is_instance_valid(message_panel):
			message_panel.hide()
	)


func submit_message(text: String) -> void:
	# Do nothing if the message is empty
	if text.strip_edges() == "": return

	# Handle commands (starting with "/")
	if text.begins_with("/"): pass # TODO: Implement commands here

	# Send the message to all peers
	send_message(text)


func _on_line_edit_text_submitted(new_text):
	submit_message(new_text)
	clear_and_hide_input()


func _on_send_pressed():
	submit_message(line_edit.text)
	clear_and_hide_input()
