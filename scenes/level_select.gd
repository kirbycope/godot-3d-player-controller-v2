extends Control

var current_index = -1

@onready var button_container = $Center/VBoxContainer
@onready var beta = button_container.get_node("Beta")
@onready var animal_crossing_new_leaf = button_container.get_node("AnimalCrossingNewLeaf")
@onready var guild_wars = button_container.get_node("GuildWars")
@onready var minecraft = button_container.get_node("Minecraft")
@onready var portal = button_container.get_node("Portal")
@onready var super_mario_galaxy = button_container.get_node("SuperMarioGalaxy")
@onready var super_mario_odyssey = button_container.get_node("SuperMarioOdyssey")
@onready var zelda_breath_of_the_wild = button_container.get_node("ZeldaBreathOfTheWild")
@onready var zelda_links_awakening = button_container.get_node("ZeldaLinksAwakening")
@onready var preview_container = $Center/CenterContainer
@onready var beta_preview = preview_container.get_node("Beta")
@onready var animal_crossing_new_leaf_preview = preview_container.get_node("AnimalCrossingNewLeaf")
@onready var guild_wars_preview = preview_container.get_node("GuildWars")
@onready var minecraft_preview = preview_container.get_node("Minecraft")
@onready var portal_preview = preview_container.get_node("Portal")
@onready var super_mario_galaxy_preview = preview_container.get_node("SuperMarioGalaxy")
@onready var super_mario_odyssey_preview = preview_container.get_node("SuperMarioOdyssey")
@onready var zelda_breath_of_the_wild_preview = preview_container.get_node("ZeldaBreathOfTheWild")
@onready var description = $Center/Description
@onready var zelda_links_awakening_preview = preview_container.get_node("ZeldaLinksAwakening")
@onready var loading = $Loading


func _ready():
	_on_beta_pressed()



func get_level_index() -> int:
	var buttons = button_container.get_children()
	for i in range(buttons.size()):
		if buttons[i].button_pressed:
			return i
	return -1


func hide_previews():
	var children = preview_container.get_children()
	for child in children:
		child.visible = false


func reset_buttons():
	var buttons = button_container.get_children()
	for button in buttons:
		button.button_pressed = false


func _on_beta_pressed():
	description.text = "Prototype level for testing all the things."
	hide_previews()
	beta_preview.visible = true
	reset_buttons()
	beta.button_pressed = true
	current_index = get_level_index()


func _on_animal_crossing_new_leaf_pressed():
	description.text = "Move the player side-to-side and rotate the world up-and-down."
	hide_previews()
	animal_crossing_new_leaf_preview.visible = true
	reset_buttons()
	animal_crossing_new_leaf.button_pressed = true
	current_index = get_level_index()


func _on_guild_wars_pressed():
	description.text = "Third-person perspective. Mouse unlocked. Click-to-move."
	hide_previews()
	guild_wars_preview.visible = true
	reset_buttons()
	guild_wars.button_pressed = true
	current_index = get_level_index()


func _on_minecraft_pressed():
	description.text = "Multiple perspectives."
	hide_previews()
	minecraft_preview.visible = true
	reset_buttons()
	minecraft.button_pressed = true
	current_index = get_level_index()


func _on_portal_pressed():
	description.text = "First-person perspective. Interact with environment."
	hide_previews()
	portal_preview.visible = true
	reset_buttons()
	portal.button_pressed = true
	current_index = get_level_index()



func _on_super_mario_galaxy_pressed():
	description.text = "Third-person perspective. Local (planetary) gravity."
	hide_previews()
	super_mario_galaxy_preview.visible = true
	reset_buttons()
	super_mario_galaxy.button_pressed = true
	current_index = get_level_index()


func _on_super_mario_odyssey_pressed():
	description.text = "Third-person perspective. 3D platforming."
	hide_previews()
	super_mario_odyssey_preview.visible = true
	reset_buttons()
	super_mario_odyssey.button_pressed = true
	current_index = get_level_index()



func _on_zelda_breath_of_the_wild_pressed():
	description.text = "Third-person perspective. Climbable surfaces. Stamina."
	hide_previews()
	zelda_breath_of_the_wild_preview.visible = true
	reset_buttons()
	zelda_breath_of_the_wild.button_pressed = true
	current_index = get_level_index()



func _on_zelda_links_awakening_pressed():
	description.text = "Top-down perspective. Locked camera."
	hide_previews()
	zelda_links_awakening_preview.visible = true
	reset_buttons()
	zelda_links_awakening.button_pressed = true
	current_index = get_level_index()


func _on_enter_level_pressed():
	if current_index != -1:
		loading.visible = true
		if current_index == 0:
			var beta_scene = load("res://scenes/beta/main.tscn").instantiate()
			get_tree().root.add_child(beta_scene)
		elif current_index == 1:
			var acnl_scene = load("res://scenes/animal_crossing_new_leaf/main.tscn").instantiate()
			get_tree().root.add_child(acnl_scene)
		elif current_index == 2:
			var gw_scene = load("res://scenes/guild_wars/main.tscn").instantiate()
			get_tree().root.add_child(gw_scene)
		elif current_index == 3:
			var mc_scene = load("res://scenes/minecraft/main.tscn").instantiate()
			get_tree().root.add_child(mc_scene)
		elif current_index == 4:
			var portal_scene = load("res://scenes/portal/main.tscn").instantiate()
			get_tree().root.add_child(portal_scene)
		elif current_index == 5:
			var smg_scene = load("res://scenes/super_mario_galaxy/main.tscn").instantiate()
			get_tree().root.add_child(smg_scene)
		elif current_index == 6:
			var smo_scene = load("res://scenes/super_mario_odyssey/main.tscn").instantiate()
			get_tree().root.add_child(smo_scene)
		elif current_index == 7:
			var zbotw_scene = load("res://scenes/zelda_breath_of_the_wild/main.tscn").instantiate()
			get_tree().root.add_child(zbotw_scene)
		elif current_index == 8:
			var zla_scene = load("res://scenes/zelda_links_awakening/main.tscn").instantiate()
			get_tree().root.add_child(zla_scene)
		queue_free()
