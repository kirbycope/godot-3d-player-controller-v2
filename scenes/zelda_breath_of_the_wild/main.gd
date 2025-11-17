extends Node3D
## Zelda: Breath of the Wild scene configuration.

@onready var player: CharacterBody3D = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.camera.set_camera_perspective(player.camera.Perspective.THIRD_PERSON)
	player.enable_climbing = true
	player.enable_crawling = true
	player.enable_crouching = true
	player.enable_hanging = true
	player.enable_jumping = true
	player.enable_paragliding = true
	player.enable_sprinting = true
	player.enable_swimming = true
