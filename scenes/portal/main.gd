extends Node3D

@onready var player = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.camera.lock_camera = false
	player.enable_climbing = false
	player.enable_crawling = true
	player.enable_crouching = true
	player.enable_double_jumping = false
	player.enable_flying = false
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
	player.camera.enable_head_bobbing = false
	player.camera.toggle_perspective()


func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		print("Player is on the button.")


func _on_area_3d_body_exited(body):
	if body is CharacterBody3D:
		print("Player moved off of the button.")


func _on_pedestal_area_3d_body_entered(body):
	if body is CharacterBody3D:
			print("Player is near the button.")


func _on_pedestal_area_3d_body_exited(body):
	if body is CharacterBody3D:
			print("Player moved away from the button.")
