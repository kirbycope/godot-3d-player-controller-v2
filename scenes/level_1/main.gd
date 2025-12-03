extends Node3D
## Animal Crossing: New Leaf scene configuration.

@onready var ground: StaticBody3D = $Ground
@onready var player: CharacterBody3D = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.camera.lock_camera = true
	player.camera.lock_perspective = true
	player.camera.rotation.x = deg_to_rad(-30.0)
	player.camera_mount.position.y = 2.0
	player.camera_mount.position.z = 1.5
	player.camera.set_camera_perspective(player.camera.Perspective.THIRD_PERSON)
	player.lock_movement_z = true


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Rotate the world
	# ToDo: Test potential collision with wall before rotating, do not rotate if colliding with wall
	if Input.is_action_pressed(player.controls.move_up):
		ground.rotate_x(deg_to_rad(10) * delta)
	elif Input.is_action_pressed(player.controls.move_down):
		ground.rotate_x(deg_to_rad(-10) * delta)
