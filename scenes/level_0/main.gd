extends Node3D
## Beta testbed scene enabling most features.

const SetupCharacter = preload("res://addons/3d_player_controller_v2/setup_character.gd")

@onready var player: CharacterBody3D = $Player

var characters = [
	"res://addons/3d_player_controller_v2/assets/characters/godette/godette.tscn",
	"res://addons/3d_player_controller_v2/assets/characters/mixamo/x_bot.tscn",
	"res://addons/3d_player_controller_v2/assets/characters/mixamo/y_bot.tscn",
	"res://assets/universal_animation_library/mannequin_male.tscn",
	"res://assets/universal_animation_library_2/mannequin_female.tscn",
	"res://assets/universal_base_characters/female.tscn",
	"res://assets/universal_base_characters/male.tscn",
]

var current_character_index := 0


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#player.camera.lock_camera = false
	#player.camera.lock_perspective = false
	player.camera.set_camera_perspective(player.camera.Perspective.THIRD_PERSON)
	#player.debug.show()
	player.enable_climbing = true
	player.enable_crawling = true
	player.enable_crouching = true
	#player.enable_double_jumping = true
	player.enable_driving = true
	player.enable_emotes = true
	#player.enable_flying = true
	player.enable_hanging = true
	player.enable_holding_objects = true
	player.enable_jumping = true
	player.enable_kicking = true
	#player.enable_mantling = true
	#player.enable_navigation = true
	#player.enable_paragliding = true
	player.enable_punching = true
	player.enable_pushing = true
	player.enable_ragdolling = true
	#player.enable_retical = true
	player.enable_rolling = true
	player.enable_sitting = true
	player.enable_sliding = true
	player.enable_sprinting = true
	player.enable_swimming = true
	player.enable_throwing = true
	player.enable_vibration = true
	#player.lock_movement_x = true
	#player.lock_movement_y = true
	#player.lock_movement_z = true


func _input(event: InputEvent) -> void:
	# (DPad-Up)/[Tab] _pressed_ -> Swap character model
	if event.is_action_pressed(Controls.BUTTON_12):
		if event is InputEventKey and event.echo:
			return
		# Get the current character model
		var old_character = player.character
		# Increment the character index
		current_character_index = (current_character_index + 1) % characters.size()
		print("Swapping to character model: `", characters[current_character_index], "`")
		# Instantiate the new character model
		var new_character = load(characters[current_character_index]).instantiate()
		# Rename the old character model to avoid name conflicts
		old_character.name = "DELETE_ME"
		# Name the new character model
		new_character.name = "Character"
		# Transfer transform status to the new character model
		new_character.transform = old_character.transform
		# Transfer top_level status to the new character model
		new_character.top_level = old_character.top_level
		# Add the new character model to the $Visuals node
		player.visuals.add_child(new_character)
		# Replace the `@onready var character` reference
		player.character = new_character
		# Replace the `@onready var character` reference
		player.visuals.character = new_character
		# Remove the old character model from the scene tree
		old_character.queue_free()

		# Setup animations for all `character` components
		SetupCharacter.add_animations(new_character, player)

		# Setup physical bone simulators for all `character` components
		SetupCharacter.physical_bone_simulators(new_character)

		return
