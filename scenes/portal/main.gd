extends Node3D

@onready var player = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.camera.enable_head_bobbing = false
	player.camera.toggle_perspective() # Run in _ready() to start in 1st person
	player.camera.lock_camera = false
	player.camera.lock_perspective = true
	player.enable_climbing = false
	player.enable_crawling = true
	player.enable_crouching = true
	player.enable_double_jumping = false
	player.enable_flying = false
	player.enable_holding_objects = true
	player.enable_jumping = true
	player.enable_kicking = false
	player.enable_navigation = false
	player.enable_punching = false
	player.enable_rolling = false
	player.enable_sprinting = false
	player.enable_swimming = false
	player.lock_movement_x = false
	player.lock_movement_y = false
	player.lock_movement_z = false
