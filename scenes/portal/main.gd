extends Node3D
## Portal scene script configuration.

@onready var player: CharacterBody3D = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.camera.lock_perspective = true
	player.camera.set_camera_perspective(player.camera.Perspective.FIRST_PERSON)
	player.enable_crawling = true
	player.enable_crouching = true
	player.enable_holding_objects = true
	player.enable_jumping = true
	player.enable_retical = true
	player.enable_throwing = true
