extends Camera3D

enum Perspective {
	THIRD_PERSON,
	FIRST_PERSON
}

@export var lock_camera: bool = false ## Lock camera position and location
@export var lock_perspective: bool = false ## Lock camera perspective
@export var look_sensitivity_mouse: float = 0.2 ## Mouse look sensitivity

var is_rotating_camera: bool = false
var perspective: Perspective = Perspective.THIRD_PERSON ## Camera perspective

@onready var spring_arm = get_parent()
@onready var camera_mount: Node3D = get_parent().get_parent()
@onready var player: CharacterBody3D = get_parent().get_parent().get_parent()



## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	if lock_camera:
		return

	# ⧉/[F5] _pressed_ -> Toggle "perspective"
	if event.is_action_pressed(player.controls.button_8) and not lock_perspective:
		toggle_perspective()

	# Check for mouse motion
	if event is InputEventMouseMotion:
		# Check if the mouse is captured
		if Input.get_mouse_mode() in [Input.MOUSE_MODE_CAPTURED, Input.MOUSE_MODE_HIDDEN] \
		and not is_rotating_camera:
			# Rotate camera based on mouse movement
			camera_rotate_by_mouse(event)

		# Check if the mouse is visible and the right mouse button is pressed
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE \
		and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			# Flag the camera as rotating
			is_rotating_camera = true
			# Hide the mouse
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			# Rotate camera based on mouse movement
			camera_rotate_by_mouse(event)

		# Check if the mouse is captured and the camera is rotating
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and is_rotating_camera:
			# Rotate camera based on mouse movement
			camera_rotate_by_mouse(event)

	# Check if the right mouse button is released while rotating the camera
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT \
	and event.is_pressed() == false and is_rotating_camera:
		# Flag the camera as not rotating
		is_rotating_camera = false
		# Show the mouse
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


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
	player.rotate(player.basis.y, deg_to_rad(new_rotation_y))

	# [Third-person] Rotate the visuals with the camera's horizontal rotation
	if perspective == Perspective.THIRD_PERSON:
		player.visuals.rotate_y(deg_to_rad(event.relative.x * look_sensitivity_mouse))


## Toggle between "first-person" and "third-person" perspectives.
func toggle_perspective() -> void:
	if perspective == Perspective.THIRD_PERSON:
		perspective = Perspective.FIRST_PERSON
		player.visuals.rotation.y = 0.0
		spring_arm.spring_length = 0.0
		spring_arm.position.y = 0.0
	else:
		perspective = Perspective.THIRD_PERSON
		spring_arm.spring_length = 1.5
		spring_arm.position.y = 0.7
