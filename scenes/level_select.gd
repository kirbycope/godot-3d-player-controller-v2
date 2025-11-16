extends Control
## Level selection UI and scene loading.

var current_index := -1

@onready var button_container: VBoxContainer = $Center/VBoxContainer
@onready var beta: BaseButton = button_container.get_node("Beta")
@onready var animal_crossing_new_leaf: BaseButton = button_container.get_node("AnimalCrossingNewLeaf")
@onready var guild_wars: BaseButton = button_container.get_node("GuildWars")
@onready var minecraft: BaseButton = button_container.get_node("Minecraft")
@onready var pokemon: BaseButton = button_container.get_node("PokemonLegendsZA")
@onready var portal: BaseButton = button_container.get_node("Portal")
@onready var super_mario_galaxy: BaseButton = button_container.get_node("SuperMarioGalaxy")
@onready var super_mario_odyssey: BaseButton = button_container.get_node("SuperMarioOdyssey")
@onready var zelda_breath_of_the_wild: BaseButton = button_container.get_node("ZeldaBreathOfTheWild")
@onready var zelda_links_awakening: BaseButton = button_container.get_node("ZeldaLinksAwakening")
@onready var preview_container: Control = $Center/CenterContainer
@onready var beta_preview: Control = preview_container.get_node("Beta")
@onready var animal_crossing_new_leaf_preview: Control = preview_container.get_node("AnimalCrossingNewLeaf")
@onready var guild_wars_preview: Control = preview_container.get_node("GuildWars")
@onready var minecraft_preview: Control = preview_container.get_node("Minecraft")
@onready var pokemon_preview: Control = preview_container.get_node("PokemonLegendsZA")
@onready var portal_preview: Control = preview_container.get_node("Portal")
@onready var super_mario_galaxy_preview: Control = preview_container.get_node("SuperMarioGalaxy")
@onready var super_mario_odyssey_preview: Control = preview_container.get_node("SuperMarioOdyssey")
@onready var zelda_breath_of_the_wild_preview: Control = preview_container.get_node("ZeldaBreathOfTheWild")
@onready var zelda_links_awakening_preview: Control = preview_container.get_node("ZeldaLinksAwakening")
@onready var description: Label = $Center/Description
@onready var enter_level: BaseButton = $Center/EnterLevel
@onready var loading: Control = $Loading


func _ready() -> void:
	_on_beta_pressed()
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


func _on_beta_pressed() -> void:
	description.text = "Prototype level for testing all the things."
	hide_previews()
	beta_preview.visible = true
	reset_buttons()
	beta.button_pressed = true
	current_index = get_level_index()


func _on_animal_crossing_new_leaf_pressed() -> void:
	description.text = "Move the player side-to-side and rotate the world up-and-down."
	hide_previews()
	animal_crossing_new_leaf_preview.visible = true
	reset_buttons()
	animal_crossing_new_leaf.button_pressed = true
	current_index = get_level_index()


func _on_guild_wars_pressed() -> void:
	description.text = "Third-person perspective. Mouse unlocked. Click-to-move."
	hide_previews()
	guild_wars_preview.visible = true
	reset_buttons()
	guild_wars.button_pressed = true
	current_index = get_level_index()


func _on_minecraft_pressed() -> void:
	description.text = "Multiple perspectives."
	hide_previews()
	minecraft_preview.visible = true
	reset_buttons()
	minecraft.button_pressed = true
	current_index = get_level_index()


func _on_pokemon_legends_za_pressed() -> void:
	description.text = "Third-person perspective. Rolling."
	hide_previews()
	pokemon_preview.visible = true
	reset_buttons()
	pokemon.button_pressed = true
	current_index = get_level_index()


func _on_portal_pressed() -> void:
	description.text = "First-person perspective. Interact with environment."
	hide_previews()
	portal_preview.visible = true
	reset_buttons()
	portal.button_pressed = true
	current_index = get_level_index()



func _on_super_mario_galaxy_pressed() -> void:
	description.text = "Third-person perspective. Local (planetary) gravity."
	hide_previews()
	super_mario_galaxy_preview.visible = true
	reset_buttons()
	super_mario_galaxy.button_pressed = true
	current_index = get_level_index()


func _on_super_mario_odyssey_pressed() -> void:
	description.text = "Third-person perspective. 3D platforming."
	hide_previews()
	super_mario_odyssey_preview.visible = true
	reset_buttons()
	super_mario_odyssey.button_pressed = true
	current_index = get_level_index()



func _on_zelda_breath_of_the_wild_pressed() -> void:
	description.text = "Third-person perspective. Climbable surfaces. Stamina."
	hide_previews()
	zelda_breath_of_the_wild_preview.visible = true
	reset_buttons()
	zelda_breath_of_the_wild.button_pressed = true
	current_index = get_level_index()



func _on_zelda_links_awakening_pressed() -> void:
	description.text = "Top-down perspective. Locked camera."
	hide_previews()
	zelda_links_awakening_preview.visible = true
	reset_buttons()
	zelda_links_awakening.button_pressed = true
	current_index = get_level_index()


func _on_enter_level_pressed() -> void:
	if current_index != -1:
		loading.visible = true
		if current_index == 0:
			var beta_scene: Node = load("res://scenes/beta/main.tscn").instantiate()
			get_tree().root.add_child(beta_scene)
		elif current_index == 1:
			var acnl_scene: Node = load("res://scenes/animal_crossing_new_leaf/main.tscn").instantiate()
			get_tree().root.add_child(acnl_scene)
		elif current_index == 2:
			var gw_scene: Node = load("res://scenes/guild_wars/main.tscn").instantiate()
			get_tree().root.add_child(gw_scene)
		elif current_index == 3:
			var mc_scene: Node = load("res://scenes/minecraft/main.tscn").instantiate()
			get_tree().root.add_child(mc_scene)
		elif current_index == 4:
			var pokemon_scene: Node = load("res://scenes/pokemon_legends_za/main.tscn").instantiate()
			get_tree().root.add_child(pokemon_scene)
		elif current_index == 5:
			var portal_scene: Node = load("res://scenes/portal/main.tscn").instantiate()
			get_tree().root.add_child(portal_scene)
		elif current_index == 6:
			var smg_scene: Node = load("res://scenes/super_mario_galaxy/main.tscn").instantiate()
			get_tree().root.add_child(smg_scene)
		elif current_index == 7:
			var smo_scene: Node = load("res://scenes/super_mario_odyssey/main.tscn").instantiate()
			get_tree().root.add_child(smo_scene)
		elif current_index == 8:
			var zbotw_scene: Node = load("res://scenes/zelda_breath_of_the_wild/main.tscn").instantiate()
			get_tree().root.add_child(zbotw_scene)
		elif current_index == 9:
			var zla_scene: Node = load("res://scenes/zelda_links_awakening/main.tscn").instantiate()
			get_tree().root.add_child(zla_scene)
		queue_free()


func _on_exit_pressed() -> void:
	pass # Replace with function body.
