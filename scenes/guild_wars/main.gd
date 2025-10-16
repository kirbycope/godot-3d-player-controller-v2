extends Node3D

@onready var player = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.camera.lock_camera = false
	player.enable_climbing = false
	player.enable_crawling = false
	player.enable_crouching = false
	player.enable_double_jumping = false
	player.enable_flying = false
	player.enable_holding_objects = false
	player.enable_jumping = false
	player.enable_kicking = false
	player.enable_navigation = true
	player.enable_punching = false
	player.enable_retical = false
	player.enable_rolling = false
	player.enable_sprinting = false
	player.enable_swimming = false
	player.lock_movement_x = false
	player.lock_movement_y = false
	player.lock_movement_z = false
	player.camera.enable_head_bobbing = false
	#player.camera.toggle_perspective() # Run in _ready() to start in 1st person
