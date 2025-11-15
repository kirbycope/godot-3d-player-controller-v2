extends CanvasLayer
## Manages multiplayer chat interface with message display, input handling, and RPC communication


@onready var player: CharacterBody3D = get_parent()
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var messages_container: VBoxContainer = scroll_container.get_node("VBoxContainer")
@onready var line_edit: LineEdit = $LineEdit
@onready var send_button: Button = $SEND


func _ready() -> void:
	clear_and_hide_input()


func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# (☰)/[Esc] _pressed_ -> Hide chat input
	if event.is_action_pressed(player.controls.button_9) \
	and line_edit.visible:
		clear_and_hide_input()

	# (D-Pad Right)/[T] _released_ -> Show chat input
	if event.is_action_released(player.controls.button_15) \
	and not line_edit.visible \
	and not player.emotes.visible:
		clear_and_show_input()


func clear_and_hide_input() -> void:
	line_edit.clear()
	line_edit.hide()
	send_button.hide()


func clear_and_show_input() -> void:
	line_edit.clear()
	line_edit.show()
	line_edit.grab_focus()
	send_button.show()


func get_username() -> String:
	var username := player.get("steam_id")
	if username == null:
		username = ""
	if username.is_empty():
		username = OS.get_environment("USERNAME")
	if username.is_empty():
		username = OS.get_environment("USER")
	return username


@rpc("any_peer", "call_local")
func send_message(sender: String, message: String) -> void:
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
	rtl.bbcode_enabled = true
	rtl.bbcode_text = sender + ": " + message
	rtl.custom_minimum_size = Vector2(480, 26)
	message_panel.add_child(rtl)

	# Auto-hide this message after 30 seconds (hide the whole panel)
	var timer := get_tree().create_timer(30.0)
	timer.timeout.connect(func():
		if is_instance_valid(message_panel):
			message_panel.hide()
	)

	# Wait a frame
	await get_tree().process_frame

	# Scroll to bottom
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value


func submit_message(text: String) -> void:
	# Do nothing if the message is empty
	if text.strip_edges() == "": return

	# Handle commands (starting with "/")
	if text.begins_with("/"): pass # TODO: Implement commands here

	# Get the username
	var username: String = get_username()

	# Send the message to all peers
	send_message(username, "[i]" + text)


func _on_line_edit_text_submitted(new_text: String) -> void:
	submit_message(new_text)
	clear_and_hide_input()


func _on_send_pressed() -> void:
	submit_message(line_edit.text)
	clear_and_hide_input()
