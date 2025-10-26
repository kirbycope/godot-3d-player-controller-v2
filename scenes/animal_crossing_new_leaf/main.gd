extends Node3D

const ANIMATION_RUNNING := "Running_In_Place/mixamo_com"

@onready var ground: StaticBody3D = $Ground
@onready var player = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.camera.enable_head_bobbing = false
	player.camera.lock_camera = true
	player.camera.lock_perspective = true
	player.camera.set_camera_perspective(player.camera.Perspective.THIRD_PERSON)
	player.enable_climbing = false
	player.enable_crawling = false
	player.enable_crouching = false
	player.enable_driving = false
	player.enable_double_jumping = false
	player.enable_flying = false
	player.enable_hanging = false
	player.enable_holding_objects = false
	player.enable_jumping = false
	player.enable_kicking = false
	player.enable_navigation = false
	player.enable_paragliding = false
	player.enable_punching = false
	player.enable_retical = false
	player.enable_rolling = false
	player.enable_sliding = false
	player.enable_skateboarding = false
	player.enable_sprinting = false
	player.enable_swimming = false
	player.lock_movement_x = false
	player.lock_movement_y = false
	player.lock_movement_z = true


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Rotate the world
	if Input.is_action_pressed(player.controls.move_up):
		ground.rotate_x(deg_to_rad(10) * delta)
	elif Input.is_action_pressed(player.controls.move_down):
		ground.rotate_x(deg_to_rad(-10) * delta)
