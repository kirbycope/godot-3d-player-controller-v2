extends Node3D
## Beta testbed scene enabling most features.

@onready var player: CharacterBody3D = $Player


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
	# (DPad-Up)/[Tab] _released_ -> Swap character model
	if event.is_action_pressed(Controls.BUTTON_12):
		var old_character = player.character
		var new_character = load("res://scenes/male.tscn").instantiate()
		old_character.name = "DELETE_ME"
		new_character.name = "Character"
		new_character.transform = old_character.transform
		new_character.top_level = old_character.top_level
		player.visuals.add_child(new_character)
		player.character = new_character
		old_character.queue_free()
