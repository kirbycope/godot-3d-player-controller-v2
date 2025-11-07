extends CanvasLayer

var green_sphere: MeshInstance3D
var red_sphere: MeshInstance3D
var yellow_sphere: MeshInstance3D

@onready var enable_climbing: CheckButton = $Configuration/EnableClimbing
@onready var enable_crawling: CheckButton = $Configuration/EnableCrawling
@onready var enable_crouching: CheckButton = $Configuration/EnableCrouching
@onready var enable_driving: CheckButton = $Configuration/EnableDriving
@onready var enable_double_jumping: CheckButton = $Configuration/EnableDoubleJumping
@onready var enable_emotes: CheckButton = $Configuration/EnableEmotes
@onready var enable_flying: CheckButton = $Configuration/EnableFlying
@onready var enable_hanging: CheckButton = $Configuration/EnableHanging
@onready var enable_holding_objects: CheckButton = $Configuration/EnableHoldingObjects
@onready var enable_jumping: CheckButton = $Configuration/EnableJumping
@onready var enable_kicking: CheckButton = $Configuration/EnableKicking
@onready var enable_navigation: CheckButton = $Configuration/EnableNavigation
@onready var enable_paragliding: CheckButton = $Configuration/EnableParagliding
@onready var enable_punching: CheckButton = $Configuration/EnablePunching
@onready var enable_retical: CheckButton = $Configuration/EnableRetical
@onready var enable_rolling: CheckButton = $Configuration/EnableRolling
@onready var enable_sliding: CheckButton = $Configuration/EnableSliding
@onready var enable_sprinting: CheckButton = $Configuration/EnableSprinting
@onready var enable_swimming: CheckButton = $Configuration/EnableSwimming
@onready var enable_throwing: CheckButton = $Configuration/EnableThrowing
@onready var enable_vibration: CheckButton = $Configuration2/EnableVibration
@onready var lock_camera: CheckButton = $Configuration2/LockCamera
@onready var lock_movement_x: CheckButton = $Configuration2/LockMovementX
@onready var lock_movement_y: CheckButton = $Configuration2/LockMovementY
@onready var lock_movement_z: CheckButton = $Configuration2/LockMovementZ
@onready var is_aiming_rifle: CheckBox = $States2/IsAimingRifle
@onready var is_casting_fishing: CheckBox = $States2/IsCastingFishing
@onready var is_climbing: CheckBox = $States/IsClimbing
@onready var is_climbing_ladder: CheckBox = $States/IsClimbingLadder
@onready var is_crawling: CheckBox = $States/IsCrawling
@onready var is_crouching: CheckBox = $States/IsCrouching
@onready var is_driving: CheckBox = $States/IsDriving
@onready var is_double_jumping: CheckBox = $States/IsDoubleJumping
@onready var is_falling: CheckBox = $States/IsFalling
@onready var is_firing_rifle: CheckBox = $States2/IsFiringRifle
@onready var is_flying: CheckBox = $States/IsFlying
@onready var is_hanging: CheckBox = $States/IsHanging
@onready var is_jumping: CheckBox = $States/IsJumping
@onready var is_kicking_left: CheckBox = $States2/IsKickingLeft
@onready var is_kicking_right: CheckBox = $States2/IsKickingRight
@onready var is_on_floor: CheckBox = $States2/IsOnFloor
@onready var is_punching_left: CheckBox = $States2/IsPunchingLeft
@onready var is_punching_right: CheckBox = $States2/IsPunchingRight
@onready var is_reeling_fishing: CheckBox = $States2/IsReelingFishing
@onready var is_rolling: CheckBox = $States/IsRolling
@onready var is_navigating: CheckBox = $States/IsNavigating
@onready var is_paragliding: CheckBox = $States/IsParagliding
@onready var is_running: CheckBox = $States/IsRunning
@onready var is_sliding: CheckBox = $States/IsSliding
@onready var is_skateboarding: CheckBox = $States/IsSkateboarding
@onready var is_sprinting: CheckBox = $States/IsSprinting
@onready var is_standing: CheckBox = $States/IsStanding
@onready var is_swimming: CheckBox = $States/IsSwimming
@onready var is_swinging_1h_left: CheckBox = $States2/IsSwinging1HLeft
@onready var is_swinging_1h_right: CheckBox = $States2/IsSwinging1HRight
@onready var is_throwing_left: CheckBox = $States2/IsThrowingLeft
@onready var is_throwing_right: CheckBox = $States2/IsThrowingRight
@onready var is_walking: CheckBox = $States/IsWalking
@onready var fps: Label = $Performance/FPS
@onready var player: CharacterBody3D = get_parent()
@onready var coordinates: RichTextLabel = $Control/VBoxContainer2/Coordinates
@onready var velocity: RichTextLabel = $Control/VBoxContainer2/Velocity
@onready var velocity_virtual: RichTextLabel = $Control/VBoxContainer2/VelocityVirtual


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
		enable_driving.button_pressed = player.enable_driving
		enable_emotes.button_pressed = player.enable_emotes
		enable_flying.button_pressed = player.enable_flying
		enable_hanging.button_pressed = player.enable_hanging
		enable_holding_objects.button_pressed = player.enable_holding_objects
		enable_jumping.button_pressed = player.enable_jumping
		enable_kicking.button_pressed = player.enable_kicking
		enable_navigation.button_pressed = player.enable_navigation
		enable_paragliding.button_pressed = player.enable_paragliding
		enable_punching.button_pressed = player.enable_punching
		enable_retical.button_pressed = player.enable_retical
		enable_rolling.button_pressed = player.enable_rolling
		enable_sliding.button_pressed = player.enable_sliding
		enable_sprinting.button_pressed = player.enable_sprinting
		enable_swimming.button_pressed = player.enable_swimming
		enable_throwing.button_pressed = player.enable_throwing
		enable_vibration.button_pressed = player.enable_vibration
		lock_camera.button_pressed = player.camera.lock_camera
		lock_movement_x.button_pressed = player.lock_movement_x
		lock_movement_y.button_pressed = player.lock_movement_y
		lock_movement_z.button_pressed = player.lock_movement_z
		is_aiming_rifle.button_pressed = player.is_aiming_rifle
		is_casting_fishing.button_pressed = player.is_casting_fishing
		is_climbing.button_pressed = player.is_climbing
		is_climbing_ladder.button_pressed = player.is_climbing_ladder
		is_crawling.button_pressed = player.is_crawling
		is_crouching.button_pressed = player.is_crouching
		is_driving.button_pressed = player.is_driving
		is_double_jumping.button_pressed = player.is_double_jumping
		is_falling.button_pressed = player.is_falling
		is_firing_rifle.button_pressed = player.is_firing_rifle
		is_flying.button_pressed = player.is_flying
		is_hanging.button_pressed = player.is_hanging
		is_jumping.button_pressed = player.is_jumping
		is_kicking_left.button_pressed = player.is_kicking_left
		is_kicking_right.button_pressed = player.is_kicking_right
		is_navigating.button_pressed = player.is_navigating
		is_on_floor.button_pressed = player.is_on_floor()
		is_paragliding.button_pressed = player.is_paragliding
		is_punching_left.button_pressed = player.is_punching_left
		is_punching_right.button_pressed = player.is_punching_right
		is_reeling_fishing.button_pressed = player.is_reeling_fishing
		is_rolling.button_pressed = player.is_rolling
		is_running.button_pressed = player.is_running
		is_skateboarding.button_pressed = player.is_skateboarding
		is_sliding.button_pressed = player.is_sliding
		is_sprinting.button_pressed = player.is_sprinting
		is_standing.button_pressed = player.is_standing
		is_swimming.button_pressed = player.is_swimming
		is_swinging_1h_left.button_pressed = player.is_swinging_1h_left
		is_swinging_1h_right.button_pressed = player.is_swinging_1h_right
		is_throwing_left.button_pressed = player.is_throwing_left
		is_throwing_right.button_pressed = player.is_throwing_right
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


func _on_enable_driving_toggled(toggled_on: bool) -> void:
	player.enable_driving = toggled_on


func _on_enable_emotes_toggled(toggled_on):
	player.enable_emotes = toggled_on


func _on_enable_fishing_toggled(toggled_on: bool) -> void:
	player.enable_fishing = toggled_on


func _on_enable_flying_toggled(toggled_on):
	player.enable_flying = toggled_on


func _on_enable_hanging_toggled(toggled_on: bool) -> void:
	player.enable_hanging = toggled_on


func _on_enable_holding_objects_toggled(toggled_on: bool) -> void:
	player.enable_holding_objects = toggled_on


func _on_enable_jumping_toggled(toggled_on):
	player.enable_jumping = toggled_on


func _on_enable_kicking_toggled(toggled_on):
	player.enable_kicking = toggled_on


func _on_enable_navigation_toggled(toggled_on):
	player.enable_navigation = toggled_on


func _on_enable_paragliding_toggled(toggled_on: bool) -> void:
	player.enable_paragliding = toggled_on


func _on_enable_punching_toggled(toggled_on):
	player.enable_punching = toggled_on


func _on_enable_retical_toggled(toggled_on: bool) -> void:
	player.enable_retical = toggled_on


func _on_enable_rolling_toggled(toggled_on):
	player.enable_rolling = toggled_on


func _on_enable_sliding_toggled(toggled_on: bool) -> void:
	player.enable_sliding = toggled_on


func _on_enable_sprinting_toggled(toggled_on):
	player.enable_sprinting = toggled_on


func _on_enable_swimming_toggled(toggled_on):
	player.enable_swimming = toggled_on


func _on_enable_throwing_toggled(toggled_on: bool) -> void:
	player.enable_throwing = toggled_on


func _on_enable_vibration_toggled(toggled_on):
	player.enable_vibration = toggled_on


func _on_lock_camera_toggled(toggled_on):
	player.camera.lock_camera = toggled_on


func _on_lock_movement_x_toggled(toggled_on: bool) -> void:
	player.lock_movement_x = toggled_on


func _on_lock_movement_y_toggled(toggled_on: bool) -> void:
	player.lock_movement_y = toggled_on


func _on_lock_movement_z_toggled(toggled_on: bool) -> void:
	player.lock_movement_z = toggled_on
