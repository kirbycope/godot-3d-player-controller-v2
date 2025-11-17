extends Node3D
## Zelda: Link's Awakening scene configuration.

@onready var player: CharacterBody3D = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.camera.lock_camera = true
	player.camera.lock_perspective = true
	player.camera.rotation.x = deg_to_rad(-45.0)
	player.camera_mount.position.y = 4.0
	player.camera_mount.position.z = 1.5
	player.camera.set_camera_perspective(player.camera.Perspective.THIRD_PERSON)
	player.enable_crawling = true
	player.enable_crouching = true
	player.enable_jumping = true
	player.enable_sprinting = true
	player.enable_swimming = true
