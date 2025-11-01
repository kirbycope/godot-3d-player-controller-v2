extends Camera3D

enum Perspective {
	THIRD_PERSON, # 0
	FIRST_PERSON, # 1
}

@export var enable_head_bobbing: bool = false ## Enable head bobbing effect
@export var lock_camera: bool = false ## Lock camera position and location
@export var lock_perspective: bool = false ## Lock camera perspective
@export var look_sensitivity_controller: float = 50.0 ## Mouse look sensitivity
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

	#  Ⓧ/[E] _pressed_ -> Climb ladder
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
			and not collider is VehicleBody3D:
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
	
	# 🅁1/[MB1] press to pick up an object - Throw object
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


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	if !is_multiplayer_authority(): return

	var look_actions = [player.controls.look_up, player.controls.look_down, player.controls.look_left, player.controls.look_right]
	for action in look_actions:
		# Check if the action is pressed and the camera is not locked -> Rotate camera
		if Input.is_action_pressed(action) \
		and not lock_camera:
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
				and not collider is VehicleBody3D:
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
			else:
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
			var BONE_PATH: String = player.skeleton.get_node("BoneAttachment3D")
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
