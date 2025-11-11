extends CanvasLayer

var initial_mouse_mode = -1

@onready var player: CharacterBody3D = get_parent()
@onready var settings: CanvasLayer = player.settings
@onready var panel: Panel = $Panel
@onready var pause_button = panel.get_node("VBoxContainer/PAUSE")
@onready var resume_button = panel.get_node("VBoxContainer/Resume")
@onready var settings_button = panel.get_node("VBoxContainer/Settings")
@onready var title_button = panel.get_node("VBoxContainer/Title")
@onready var exit_button = panel.get_node("VBoxContainer/Exit")


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Toggle pause menu visibility
	if event.is_action_pressed(player.controls.button_9) \
	and not player.chat.line_edit.visible:
		toggle_menu()


func toggle_menu():
	# Store the initial mouse mode
	if not visible:
		initial_mouse_mode = Input.get_mouse_mode()

	# Toggle visibility
	visible = !visible
	panel.visible = visible

	# Set initial focus
	if visible:
		resume_button.grab_focus()

	# Handle Sub-menu(s)
	if not visible:
		player.settings.visible = false

	# Show the mouse if the pause menu is visible
	if visible:
		if Input.get_mouse_mode() in [Input.MOUSE_MODE_CAPTURED, Input.MOUSE_MODE_HIDDEN]:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Restore the mouse mode to the player's preference when hiding the pause menu
	else:
		if initial_mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif initial_mouse_mode == Input.MOUSE_MODE_HIDDEN:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _on_resume_pressed():
	toggle_menu()


func _on_settings_pressed():
	player.settings.visible = !player.settings.visible
	player.settings.back.grab_focus()
	panel.visible = !player.settings.visible


func _on_title_pressed():
	var level_select_scene = load("uid://7bmrbudeq40y").instantiate()
	get_tree().root.add_child(level_select_scene)
	get_parent().get_parent().queue_free()


func _on_exit_pressed():
	# Close the application
	get_tree().quit()
