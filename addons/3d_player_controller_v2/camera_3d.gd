extends Camera3D

@export var look_sensitivity_mouse: float = 0.2 ## Mouse look sensitivity

@onready var camera_mount: Node3D = get_parent()
@onready var player: CharacterBody3D = get_parent().get_parent()


## Rotate camera using the mouse motion.
func camera_rotate_by_mouse(event: InputEvent) -> void:
	# Determine the new X-rotation based on the mouse Y-movement
	var new_rotation_x = camera_mount.rotation_degrees.x - event.relative.y * look_sensitivity_mouse

	# Limit how far the camera can rotate
	new_rotation_x = clamp(new_rotation_x, -80, 90)

	# Rotate the camera mount along the x-axis (up/down, "pitch")
	camera_mount.rotation_degrees.x = new_rotation_x

	# Rotate the player along the y-axis (left/right, "yaw")
	var new_rotation_y = -event.relative.x * look_sensitivity_mouse
	player.rotate_y(deg_to_rad(new_rotation_y))

	# [Third-person] Rotate the visuals with the camera's horizontal rotation
	if player.perspective == player.Perspective.THIRD_PERSON:
		player.visuals.rotate_y(deg_to_rad(event.relative.x * look_sensitivity_mouse))
