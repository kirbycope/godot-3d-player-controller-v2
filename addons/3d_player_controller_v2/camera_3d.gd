extends Camera3D

enum Perspective {
	THIRD_PERSON, # 0
	FIRST_PERSON, # 1
}

const BONE_PATH: String = "Godette/Rig/GeneralSkeleton/BoneAttachment3D"

@export var enable_head_bobbing: bool = false ## Enable head bobbing effect
@export var lock_camera: bool = false ## Lock camera position and location
@export var lock_perspective: bool = false ## Lock camera perspective
@export var look_sensitivity_mouse: float = 0.2 ## Mouse look sensitivity

var is_rotating_camera: bool = false
var perspective: Perspective = Perspective.FIRST_PERSON ## Camera perspective

@onready var camera_spring_arm = get_parent()
@onready var camera_mount: Node3D = get_parent().get_parent()
@onready var contextual_controls: Label = $ContextualControls
@onready var item_spring_arm = camera_mount.get_node("ItemSpringArm")
@onready var player: CharacterBody3D = get_parent().get_parent().get_parent()
@onready var ray_cast = $RayCast3D
@onready var retical: TextureRect = $Retical


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ray_cast.add_exception(player)


## Called when there is an input event.
func _input(event) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	if lock_camera:
		return

	# ⧉/[F5] _pressed_ -> Toggle "perspective"
	if event.is_action_pressed(player.controls.button_8) \
	and not lock_perspective:
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
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED \
		and is_rotating_camera:
			# Rotate camera based on mouse movement
			camera_rotate_by_mouse(event)

	# Check if the right mouse button is released while rotating the camera
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_RIGHT \
	and event.is_pressed() == false and is_rotating_camera:
		# Flag the camera as not rotating
		is_rotating_camera = false
		# Show the mouse
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Ⓧ/[E] press to pick up an object - Release object
	if event.is_action_pressed(player.controls.button_2) \
	and player.enable_holding_objects \
	and item_spring_arm.get_child_count() != 0:
		# Get the [first] child node of the item spring arm
		var child = item_spring_arm.get_child(0)
		# Change the collision layer from 2 to 1 (to allow collisions again)
		child.set_collision_layer_value(1, true)
		child.set_collision_layer_value(2, false)
		# Unfreeze the rigidbody and give it the player's velocity
		if child is RigidBody3D:
			child.freeze = false
		# Reparent the child object back to its original parent (assuming that's the Player's parent too)
		child.reparent(player.get_parent(), true)

	# Ⓧ/[E] press to pick up an object - Pickup object
	if event.is_action_pressed(player.controls.button_2) \
	and player.enable_holding_objects \
	and item_spring_arm.get_child_count() == 0:
		# Check for a collision with the raycast
		if ray_cast.is_colliding():
			# Get the collision object
			var collider = ray_cast.get_collider()
			# Check if the collider is a rigidbody3D
			if collider is RigidBody3D:
				# Check if the collider is not already a child of the item spring arm
				if collider.get_parent() != item_spring_arm:
					# Change the collision layer from 1 to 2 (to avoid further collisions)
					collider.set_collision_layer_value(1, false)
					collider.set_collision_layer_value(2, true)
					# Freeze the rigidbody to prevent physics simulation while holding
					collider.freeze = true
					# Reset the rotation
					collider.rotation = Vector3.ZERO
					# Reparent the Ridgidbody3D to the item mount
					collider.reparent(item_spring_arm)
	
	# 🅁1/[MB1] press to pick up an object - Release object
	if event.is_action_pressed(player.controls.button_5) \
	and player.enable_holding_objects \
	and item_spring_arm.get_child_count() != 0:
		# Get the [first] child node of the item spring arm
		var child = item_spring_arm.get_child(0)
		# Change the collision layer from 2 to 1 (to allow collisions again)
		child.set_collision_layer_value(1, true)
		child.set_collision_layer_value(2, false)
		# Unfreeze the rigidbody and give it the player's velocity
		if child is RigidBody3D:
			child.freeze = false
		# Reparent the child object back to its original parent (assuming that's the Player's parent too)
		child.reparent(player.get_parent(), true)
		# Apply an impulse to the object in the direction the camera is facing
		var force_direction = -global_transform.basis.z.normalized()
		child.apply_impulse(force_direction * 5.0, Vector3.ZERO)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	if !is_multiplayer_authority(): return

	if contextual_controls:
		contextual_controls.text = ""
		if item_spring_arm.get_child_count() == 0:
			if ray_cast.is_colliding():
				var collider = ray_cast.get_collider()
				if collider is RigidBody3D:
					contextual_controls.text = "Press [E] to pickup"
		else:
			contextual_controls.text = "Press [E] to release \nPress [RMB] to throw"

	retical.visible = player.enable_retical


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


## Set the camera's perspective.
func set_camera_perspective(mode: Perspective) -> void:
	if mode == Perspective.THIRD_PERSON:
		perspective = Perspective.THIRD_PERSON
		if get_parent() != camera_spring_arm:
			reparent(camera_spring_arm)
		camera_spring_arm.spring_length = 1.5
		camera_spring_arm.position.x = 0.0
		camera_spring_arm.position.y = 0.7
		camera_spring_arm.position.z = 0.0	
		ray_cast.position.z = -1.5
	else:
		perspective = Perspective.FIRST_PERSON
		player.visuals.rotation.y = 0.0
		if enable_head_bobbing:
			reparent(player.visuals.get_node(BONE_PATH))
		else:
			camera_spring_arm.spring_length = 0.0
			camera_spring_arm.position.x = 0.0
			camera_spring_arm.position.y = 0.0
			camera_spring_arm.position.z = -0.4
			ray_cast.position.z = 0.0


## Toggle between "first-person" and "third-person" perspectives.
func toggle_perspective() -> void:
	if perspective == Perspective.FIRST_PERSON:
		set_camera_perspective(Perspective.THIRD_PERSON)
	else:
		set_camera_perspective(Perspective.FIRST_PERSON)
