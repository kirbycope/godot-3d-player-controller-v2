extends Node3D

@onready var player = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.camera.enable_head_bobbing = false
	player.camera.lock_camera = false
	player.camera.lock_perspective = false
	player.camera.set_camera_perspective(player.camera.Perspective.THIRD_PERSON)
	player.enable_climbing = true
	player.enable_crawling = true
	player.enable_crouching = true
	player.enable_driving = true
	player.enable_double_jumping = false
	player.enable_flying = false
	player.enable_hanging = true
	player.enable_holding_objects = true
	player.enable_jumping = true
	player.enable_kicking = true
	player.enable_navigation = false
	player.enable_paragliding = false
	player.enable_punching = true
	player.enable_retical = true
	player.enable_rolling = true
	player.enable_sliding = true
	player.enable_skateboarding = true
	player.enable_sprinting = true
	player.enable_swimming = true
	player.lock_movement_x = false
	player.lock_movement_y = false
	player.lock_movement_z = false
