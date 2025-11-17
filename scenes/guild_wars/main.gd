extends Node3D
## Guild Wars scene configuration (click-to-move, mouse visible).

@onready var player: CharacterBody3D = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.camera.lock_perspective = true
	player.camera.set_camera_perspective(player.camera.Perspective.THIRD_PERSON)
	player.enable_navigation = true
