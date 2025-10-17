extends CanvasLayer

var green_sphere: MeshInstance3D
var red_sphere: MeshInstance3D
var yellow_sphere: MeshInstance3D

@onready var enable_climbing = $Configuration/EnableClimbing
@onready var enable_crawling = $Configuration/EnableCrawling
@onready var enable_crouching = $Configuration/EnableCrouching
@onready var enable_double_jumping = $Configuration/EnableDoubleJumping
@onready var enable_flying = $Configuration/EnableFlying
@onready var enable_hanging = $Configuration/EnableHanging
@onready var enable_holding_objects = $Configuration/EnableHoldingObjects
@onready var enable_jumping = $Configuration/EnableJumping
@onready var enable_kicking = $Configuration/EnableKicking
@onready var enable_navigation = $Configuration/EnableNavigation
@onready var enable_punching = $Configuration/EnablePunching
@onready var enable_retical = $Configuration/EnableRetical
@onready var enable_rolling = $Configuration/EnableRolling
@onready var enable_sprinting = $Configuration/EnableSprinting
@onready var enable_swimming = $Configuration/EnableSwimming
@onready var lock_camera = $Configuration/LockCamera
@onready var lock_movement_x = $Configuration/LockMovementX
@onready var lock_movement_y = $Configuration/LockMovementY
@onready var lock_movement_z = $Configuration/LockMovementZ
@onready var is_climbing: CheckBox = $States/IsClimbing
@onready var is_crawling = $States/IsCrawling
@onready var is_crouching = $States/IsCrouching
@onready var is_falling = $States/IsFalling
@onready var is_hanging = $States/IsHanging
@onready var is_jumping = $States/IsJumping
@onready var is_kicking_left = $States/IsKickingLeft
@onready var is_kicking_right = $States/IsKickingRight
@onready var is_on_floor = $States/IsOnFloor
@onready var is_punching_left = $States/IsPunchingLeft
@onready var is_punching_right = $States/IsPunchingRight
@onready var is_navigating = $States/IsNavigating
@onready var is_running = $States/IsRunning
@onready var is_sprinting = $States/IsSprinting
@onready var is_standing = $States/IsStanding
@onready var is_walking = $States/IsWalking
@onready var fps = $Performance/FPS
@onready var player: CharacterBody3D = get_parent()
@onready var coordinates = $Control/VBoxContainer2/Coordinates
@onready var velocity = $Control/VBoxContainer2/Velocity
@onready var velocity_virtual = $Control/VBoxContainer2/VelocityVirtual


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Toggle debug visibility
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		visible = !visible


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Update debug info if visible
	if visible:
		enable_climbing.button_pressed = player.enable_climbing
		enable_crawling.button_pressed = player.enable_crawling
		enable_crouching.button_pressed = player.enable_crouching
		enable_double_jumping.button_pressed = player.enable_double_jumping
		enable_flying.button_pressed = player.enable_flying
		enable_hanging.button_pressed = player.enable_hanging
		enable_jumping.button_pressed = player.enable_jumping
		enable_kicking.button_pressed = player.enable_kicking
		enable_navigation.button_pressed = player.enable_navigation
		enable_punching.button_pressed = player.enable_punching
		enable_retical.button_pressed = player.enable_retical
		enable_rolling.button_pressed = player.enable_rolling
		enable_sprinting.button_pressed = player.enable_sprinting
		enable_swimming.button_pressed = player.enable_swimming
		lock_camera.button_pressed = player.camera.lock_camera
		lock_movement_x.button_pressed = player.lock_movement_x
		lock_movement_y.button_pressed = player.lock_movement_y
		lock_movement_z.button_pressed = player.lock_movement_z
		is_climbing.button_pressed = player.is_climbing
		is_crawling.button_pressed = player.is_crawling
		is_crouching.button_pressed = player.is_crouching
		is_falling.button_pressed = player.is_falling
		is_hanging.button_pressed = player.is_hanging
		is_jumping.button_pressed = player.is_jumping
		is_kicking_left.button_pressed = player.is_kicking_left
		is_kicking_right.button_pressed = player.is_kicking_right
		is_on_floor.button_pressed = player.is_on_floor()
		is_punching_left.button_pressed = player.is_punching_left
		is_punching_right.button_pressed = player.is_punching_right
		is_navigating.button_pressed = player.is_navigating
		is_running.button_pressed = player.is_running
		is_sprinting.button_pressed = player.is_sprinting
		is_standing.button_pressed = player.is_standing
		is_walking.button_pressed = player.is_walking
		coordinates.text = "[center][color=red]X:[/color]%.1f [color=green]Y:[/color]%.1f [color=blue]Z:[/color]%.1f[/center]" % [player.global_position.x, player.global_position.y, player.global_position.z]
		velocity.text = "[center][color=red]X:[/color]%.1f [color=green]Y:[/color]%.1f [color=blue]Z:[/color]%.1f[/center]" % [player.velocity.x, player.velocity.y, player.velocity.z]
		velocity_virtual.text = "[center][color=red]X:[/color]%.1f [color=green]Y:[/color]%.1f [color=blue]Z:[/color]%.1f[/center]" % [player.virtual_velocity.x, player.virtual_velocity.y, player.virtual_velocity.z]
		fps.text = "FPS: %d" % Engine.get_frames_per_second()


## Draws a debug sphere at the specified position and with the specified color.
func draw_debug_sphere(pos: Vector3, color: Color) -> MeshInstance3D:
	# Create a new mesh instance for the debug sphere
	var debug_sphere = MeshInstance3D.new()
	# Add the debug sphere to the scene tree
	player.get_tree().get_root().add_child(debug_sphere)
	# Create a visual sphere mesh
	var sphere_mesh = SphereMesh.new()
	# Set the radius of the sphere mesh
	sphere_mesh.radius = 0.1
	# Set the height of the sphere mesh
	sphere_mesh.height = 0.2
	# Add the visual mesh to the debug sphere's "mesh"property
	debug_sphere.mesh = sphere_mesh
	# Create a new material for the debug sphere
	var material = StandardMaterial3D.new()
	# Set the albedo color of the material to the specified color
	material.albedo_color = color
	# Add the material to the debug sphere's "material_override"
	debug_sphere.material_override = material
	debug_sphere.global_position = pos
	# Return the debug sphere instance
	return debug_sphere


## 🟢 Place/Move a green debug sphere at the specified position.
func draw_green_sphere(pos: Vector3) -> void:
	if green_sphere:
		green_sphere.queue_free()
	green_sphere = draw_debug_sphere(pos, Color.GREEN)


## 🔴 Place/Move a red debug sphere at the specified position.
func draw_red_sphere(pos: Vector3) -> void:
	if red_sphere:
		red_sphere.queue_free()
	red_sphere = draw_debug_sphere(pos, Color.RED)


## 🟡 Place/Move a yellow debug sphere at the specified position.
func draw_yellow_sphere(pos: Vector3) -> void:
	if yellow_sphere:
		yellow_sphere.queue_free()
	yellow_sphere = draw_debug_sphere(pos, Color.YELLOW)


func _on_enable_climbing_toggled(toggled_on):
	player.enable_climbing = toggled_on


func _on_enable_crawling_toggled(toggled_on):
	player.enable_crawling = toggled_on


func _on_enable_crouching_toggled(toggled_on):
	player.enable_crouching = toggled_on


func _on_enable_double_jumping_toggled(toggled_on):
	player.enable_double_jumping = toggled_on


func _on_enable_flying_toggled(toggled_on):
	player.enable_flying = toggled_on


func _on_enable_hanging_toggled(toggled_on: bool) -> void:
	player.enable_hanging


func _on_enable_jumping_toggled(toggled_on):
	player.enable_jumping = toggled_on


func _on_enable_kicking_toggled(toggled_on):
	player.enable_kicking = toggled_on


func _on_enable_navigation_toggled(toggled_on):
	player.enable_navigation = toggled_on


func _on_enable_punching_toggled(toggled_on):
	player.enable_punching = toggled_on


func _on_enable_retical_toggled(toggled_on: bool) -> void:
	player.enable_retical = toggled_on


func _on_enable_rolling_toggled(toggled_on):
	player.enable_rolling = toggled_on


func _on_enable_sprinting_toggled(toggled_on):
	player.enable_sprinting = toggled_on


func _on_enable_swimming_toggled(toggled_on):
	player.enable_swimming = toggled_on


func _on_lock_camera_toggled(toggled_on):
	player.camera.lock_camera = toggled_on


func _on_lock_movement_x_toggled(toggled_on: bool) -> void:
	player.lock_movement_x = toggled_on


func _on_lock_movement_y_toggled(toggled_on: bool) -> void:
	player.lock_movement_y = toggled_on


func _on_lock_movement_z_toggled(toggled_on: bool) -> void:
	player.lock_movement_z = toggled_on
