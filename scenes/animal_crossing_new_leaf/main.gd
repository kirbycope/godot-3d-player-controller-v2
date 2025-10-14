extends Node3D

@onready var player = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.camera.lock_camera = true
	player.enable_climbing = false
	player.enable_crawling = false
	player.enable_crouching = false
	player.enable_double_jumping = false
	player.enable_flying = false
	player.enable_jumping = false
	player.enable_kicking = false
	player.enable_navigation = false
	player.enable_punching = false
	player.enable_rolling = false
	player.enable_sprinting = false
	player.enable_swimming = false
	player.lock_movement_x = false
	player.lock_movement_y = false
	player.lock_movement_z = true ## Don't allow the player to move forward and backward (using velocity)
