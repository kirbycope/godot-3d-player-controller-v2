extends Camera3D
## Manages camera perspectives, rotation, zoom, and object interaction with first/third-person modes

enum Perspective {
	THIRD_PERSON, # 0
	FIRST_PERSON, # 1
}

@export var lock_camera := false ## Lock camera position and location
@export var lock_perspective := false ## Lock camera perspective
@export var look_sensitivity_controller := 50.0 ## Mouse look sensitivity
@export var look_sensitivity_mouse := 0.2 ## Mouse look sensitivity
@export var zoom_max := 4.0 ## Maximum camera zoom distance (third-person spring length upper bound)
@export var zoom_min := 0.5 ## Minimum camera zoom distance (third-person spring length lower bound)
@export var zoom_speed := 0.2 ## Camera zoom speed

var is_rotating_camera := false ## Is the player holding the right mouse button to rotate the camera?
var perspective: Perspective = Perspective.FIRST_PERSON ## Camera perspective

@onready var camera_spring_arm: SpringArm3D = get_parent()
@onready var camera_mount: Node3D = get_parent().get_parent()
@onready var contextual_controls: Label = $ContextualControls
@onready var item_spring_arm: SpringArm3D = camera_mount.get_node("ItemSpringArm")
@onready var player: CharacterBody3D = get_parent().get_parent().get_parent()
@onready var ray_cast: RayCast3D = $RayCast3D
@onready var retical: TextureRect = $Retical


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ray_cast.add_exception(player)
	# Remove any baked local tilt from the Camera3D node
	rotation_degrees = Vector3.ZERO


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Do nothing if the camera is locked
	if lock_camera: return

	# ⧉/[F5] _pressed_ -> Toggle "perspective"
	if event.is_action_pressed(player.controls.button_8) \
	and not lock_perspective:
		toggle_perspective()

	# Check for mouse motion
	if event is InputEventMouseMotion:
		# Check if the mouse is captured/hidden and the camera is not rotating -> Rotate camera
		if Input.get_mouse_mode() in [Input.MOUSE_MODE_CAPTURED, Input.MOUSE_MODE_HIDDEN] \
		and not is_rotating_camera:
			camera_rotate_by_mouse(event)

		# Check if the mouse is visible and the right mouse button is pressed -> Start rotating camera
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE \
		and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			is_rotating_camera = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			camera_rotate_by_mouse(event)

		# Check if the mouse is captured and the camera is rotating -> Activley rotating camera
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED \
		and is_rotating_camera:
			camera_rotate_by_mouse(event)

	# Check if the right mouse button is released while rotating the camera -> Stop rotating camera
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_RIGHT \
	and event.is_pressed() == false and is_rotating_camera:
		is_rotating_camera = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Ⓨ/[Ctrl] _pressed_ -> Lower camera
	if event.is_action_pressed(player.controls.button_3):
		if perspective == Perspective.FIRST_PERSON:
			camera_mount.position.y = 0.6 # Adjust as needed

	# Ⓨ/[Ctrl] _released_ -> Raise camera
	if event.is_action_released(player.controls.button_3):
		if perspective == Perspective.FIRST_PERSON:
			camera_mount.position.y = 1.6 # Adjust as needed

	# Ⓧ/[E] _pressed_ -> Climb ladder
	if event.is_action_pressed(player.controls.button_2) \
	and ray_cast.is_colliding() \
	and not player.is_climbing_ladder:
		var collider = ray_cast.get_collider()
		if collider.is_in_group("Ladder"):
			player.base_state.transition_state(player.current_state, States.State.CLIMBING_LADDER)
			return

	# Ⓧ/[E] _pressed_ -> Release object
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

	# Ⓧ/[E] _pressed_ -> Pickup object
	if event.is_action_pressed(player.controls.button_2) \
	and player.enable_holding_objects \
	and item_spring_arm.get_child_count() == 0:
		# Check for a collision with the raycast
		if ray_cast.is_colliding():
			# Get the collision object
			var collider = ray_cast.get_collider()
			# Check if the collider is a rigidbody3D
			if collider is RigidBody3D\
			and not collider is VehicleBody3D \
			and not collider.is_in_group("NoPickUp"):
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
	
	# 🅁1/[MB1] press to pick up an object -> Throw object
	if event.is_action_pressed(player.controls.button_5) \
	and player.enable_throwing \
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
		#player.base_state.transition_state(player.current_state, States.State.THROWING)

	# Ⓛ3/[M-Scroll-Up] _pressed_ -> Zoom out (third-person only)
	if event.is_action_pressed(player.controls.button_10) \
	and perspective == Perspective.THIRD_PERSON:
		camera_spring_arm.spring_length = clamp(
			camera_spring_arm.spring_length - zoom_speed,
			zoom_min,
			zoom_max,
		)
		ray_cast.position.z = -camera_spring_arm.spring_length

	# Ⓡ3/[M-Scroll-Down] _pressed_ -> Zoom in (third-person only)
	if event.is_action_pressed(player.controls.button_11) \
	and perspective == Perspective.THIRD_PERSON:
		camera_spring_arm.spring_length = clamp(
			camera_spring_arm.spring_length + zoom_speed,
			zoom_min,
			zoom_max,
		)
		ray_cast.position.z = -camera_spring_arm.spring_length


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !is_multiplayer_authority(): return

	if perspective == Perspective.FIRST_PERSON:
		move_camera_to_player_head()

	var look_actions = [player.controls.look_up, player.controls.look_down, player.controls.look_left, player.controls.look_right]
	for action in look_actions:
		# Check if the action is pressed and the camera is not locked -> Rotate camera
		if Input.is_action_pressed(action) \
		and not lock_camera \
		and not player.pause.visible:
			camera_rotate_by_controller(delta)
		# Check if the mouse is captured/hidden and the camera is not rotating -> Rotate camera
		if Input.get_mouse_mode() in [Input.MOUSE_MODE_CAPTURED, Input.MOUSE_MODE_HIDDEN] \
		and not is_rotating_camera:
			camera_rotate_by_controller(delta)

	if contextual_controls:
		contextual_controls.text = ""
		if item_spring_arm.get_child_count() == 0:
			if ray_cast.is_colliding():
				var collider = ray_cast.get_collider()
				if collider is RigidBody3D \
				and not collider is VehicleBody3D \
				and not collider.is_in_group("NoPickUp") \
				and player.enable_holding_objects:
					contextual_controls.text = "Press [E] to pickup"
				elif collider is VehicleBody3D \
				and not player.is_driving:
					contextual_controls.text = "Press [E] to drive"
				elif collider.is_in_group("Ladder"):
					if player.is_climbing_ladder:
						contextual_controls.text = "Press [Ctrl] to release"
					else:
						contextual_controls.text = "Press [E] to climb"
		else:
			if player.enable_throwing:
				contextual_controls.text = "Press [E] to release \nPress [RMB] to throw"
			elif player.enable_holding_objects:
				contextual_controls.text = "Press [E] to release"

	retical.visible = player.enable_retical


## Rotate camera using the controller.
func camera_rotate_by_controller(delta: float) -> void:
	var input_x = Input.get_action_strength(player.controls.look_right) - Input.get_action_strength(player.controls.look_left)
	var input_y = Input.get_action_strength(player.controls.look_up) - Input.get_action_strength(player.controls.look_down)

	var new_rotation_x = camera_mount.rotation_degrees.x + input_y * look_sensitivity_controller * delta
	new_rotation_x = clamp(new_rotation_x, -80, 90)
	camera_mount.rotation_degrees.x = new_rotation_x
	var new_rotation_y = -input_x * look_sensitivity_controller * delta
	player.rotate(player.basis.y, deg_to_rad(new_rotation_y))
	if perspective == Perspective.THIRD_PERSON:
		player.visuals.rotate_y(deg_to_rad(input_x * look_sensitivity_controller * delta))


## Rotate camera using the mouse motion.
func camera_rotate_by_mouse(event: InputEvent) -> void:
	var new_rotation_x = camera_mount.rotation_degrees.x - event.relative.y * look_sensitivity_mouse
	new_rotation_x = clamp(new_rotation_x, -80, 90)
	camera_mount.rotation_degrees.x = new_rotation_x
	var new_rotation_y = -event.relative.x * look_sensitivity_mouse
	player.rotate(player.basis.y, deg_to_rad(new_rotation_y))
	if perspective == Perspective.THIRD_PERSON:
		player.visuals.rotate_y(deg_to_rad(event.relative.x * look_sensitivity_mouse))


## Update the camera to follow the character head's position (while in "first person").
func move_camera_to_player_head() -> void:
	var bone_index = player.skeleton.find_bone(player.bone_name_head)
	var bone_pose = player.skeleton.get_bone_global_pose(bone_index)
	var bone_world_pos = player.skeleton.global_transform * bone_pose.origin
	global_position = bone_world_pos
	global_rotation = camera_mount.global_rotation
	global_position += global_transform.basis.z * -0.15 # Adjust as needed


## Set the camera's perspective.
func set_camera_perspective(mode: Perspective) -> void:
	if mode == Perspective.THIRD_PERSON:
		perspective = Perspective.THIRD_PERSON
		player.visuals.rotation = Vector3.ZERO
		ray_cast.position.z = -camera_spring_arm.spring_length
		camera_mount.rotation_degrees.x = 0.0
		camera_mount.rotation_degrees.z = 0.0
	else:
		perspective = Perspective.FIRST_PERSON
		player.visuals.rotation = Vector3(0.0, 0.0, camera_mount.rotation.z)
		ray_cast.position.z = 0.0


## Toggle between "first-person" and "third-person" perspectives.
func toggle_perspective() -> void:
	if perspective == Perspective.FIRST_PERSON:
		set_camera_perspective(Perspective.THIRD_PERSON)
	else:
		set_camera_perspective(Perspective.FIRST_PERSON)
