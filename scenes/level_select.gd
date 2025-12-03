extends Control
## Level selection UI and scene loading.

var current_index := -1

@onready var button_container: VBoxContainer = $Center/VBoxContainer
@onready var level0: BaseButton = button_container.get_node("Level0")
@onready var level1: BaseButton = button_container.get_node("Level1")
@onready var level2: BaseButton = button_container.get_node("Level2")
@onready var level3: BaseButton = button_container.get_node("Level3")
@onready var level4: BaseButton = button_container.get_node("Level4")
@onready var level5: BaseButton = button_container.get_node("Level5")
@onready var level6: BaseButton = button_container.get_node("Level6")
@onready var level7: BaseButton = button_container.get_node("Level7")
@onready var level8: BaseButton = button_container.get_node("Level8")
@onready var preview_container: Control = $Center/CenterContainer
@onready var level0_preview: Control = preview_container.get_node("Level0")
@onready var level1_preview: Control = preview_container.get_node("Level1")
@onready var level2_preview: Control = preview_container.get_node("Level2")
@onready var level3_preview: Control = preview_container.get_node("Level3")
@onready var level4_preview: Control = preview_container.get_node("Level4")
@onready var level5_preview: Control = preview_container.get_node("Level5")
@onready var level6_preview: Control = preview_container.get_node("Level6")
@onready var level7_preview: Control = preview_container.get_node("Level7")
@onready var level8_preview: Control = preview_container.get_node("Level8")
@onready var description: Label = $Center/Description
@onready var enter_level: BaseButton = $Center/EnterLevel
@onready var loading: Control = $Loading


func _ready() -> void:
	_on_level0_pressed()
	enter_level.grab_focus()


func get_level_index() -> int:
	var buttons := button_container.get_children()
	for i in range(buttons.size()):
		if buttons[i].button_pressed:
			return i
	return -1


func hide_previews() -> void:
	var children := preview_container.get_children()
	for child in children:
		child.visible = false


func reset_buttons() -> void:
	var buttons := button_container.get_children()
	for button in buttons:
		button.button_pressed = false


func _on_level0_pressed() -> void:
	description.text = "Prototype level for testing all the things."
	hide_previews()
	level0_preview.visible = true
	reset_buttons()
	level0.button_pressed = true
	current_index = get_level_index()


func _on_level1_pressed() -> void:
	description.text = "Move the player side-to-side and rotate the world up-and-down."
	hide_previews()
	level1_preview.visible = true
	reset_buttons()
	level1.button_pressed = true
	current_index = get_level_index()


func _on_level2_pressed() -> void:
	description.text = "Third-person perspective. Mouse unlocked. Click-to-move."
	hide_previews()
	level2_preview.visible = true
	reset_buttons()
	level2.button_pressed = true
	current_index = get_level_index()


func _on_level3_pressed() -> void:
	description.text = "Multiple perspectives."
	hide_previews()
	level3_preview.visible = true
	reset_buttons()
	level3.button_pressed = true
	current_index = get_level_index()


func _on_level4_pressed() -> void:
	description.text = "Third-person perspective. Rolling."
	hide_previews()
	level4_preview.visible = true
	reset_buttons()
	level4.button_pressed = true
	current_index = get_level_index()


func _on_level5_pressed() -> void:
	description.text = "First-person perspective. Interact with environment."
	hide_previews()
	level5_preview.visible = true
	reset_buttons()
	level5.button_pressed = true
	current_index = get_level_index()


func _on_level6_pressed() -> void:
	description.text = "Third-person perspective. Local (planetary) gravity."
	hide_previews()
	level6_preview.visible = true
	reset_buttons()
	level6.button_pressed = true
	current_index = get_level_index()


func _on_level7_pressed() -> void:
	description.text = "Third-person perspective. Climbable surfaces. Stamina."
	hide_previews()
	level7_preview.visible = true
	reset_buttons()
	level7.button_pressed = true
	current_index = get_level_index()


func _on_level8_pressed() -> void:
	description.text = "Top-down perspective. Locked camera."
	hide_previews()
	level8_preview.visible = true
	reset_buttons()
	level8.button_pressed = true
	current_index = get_level_index()


func _on_enter_level_pressed() -> void:
	if current_index != -1:
		loading.visible = true
		if current_index == 0:
			var scene: Node = load("res://scenes/level_0/main.tscn").instantiate()
			get_tree().root.add_child(scene)
		elif current_index == 1:
			var scene: Node = load("res://scenes/level_1/main.tscn").instantiate()
			get_tree().root.add_child(scene)
		elif current_index == 2:
			var scene: Node = load("res://scenes/level_2/main.tscn").instantiate()
			get_tree().root.add_child(scene)
		elif current_index == 3:
			var scene: Node = load("res://scenes/level_3/main.tscn").instantiate()
			get_tree().root.add_child(scene)
		elif current_index == 4:
			var scene: Node = load("res://scenes/level_4/main.tscn").instantiate()
			get_tree().root.add_child(scene)
		elif current_index == 5:
			var scene: Node = load("res://scenes/level_5/main.tscn").instantiate()
			get_tree().root.add_child(scene)
		elif current_index == 6:
			var scene: Node = load("res://scenes/level_6/main.tscn").instantiate()
			get_tree().root.add_child(scene)
		elif current_index == 7:
			var scene: Node = load("res://scenes/level_7/main.tscn").instantiate()
			get_tree().root.add_child(scene)
		elif current_index == 8:
			var scene: Node = load("res://scenes/level_8/main.tscn").instantiate()
			get_tree().root.add_child(scene)
		queue_free()


func _on_exit_pressed() -> void:
	get_tree().quit()
