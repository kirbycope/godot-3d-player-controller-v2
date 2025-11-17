extends Node3D

var exit_portal: Portal3D
var player: CharacterBody3D
var player_camera: Camera3D

@onready var portal_3d: Portal3D = $Portal3D

# Load the Portal 2-like material
const BLUE_PORTAL_MATERIAL = preload("res://scenes/portal/materials/blue_portal_material.tres")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Defer wiring until all siblings finish _ready to avoid Portal3D initializing too early
	await get_tree().process_frame

	# Get the "red" portal
	exit_portal = $"../RedPortal/Portal3D"
	if exit_portal == null:
		push_error("BluePortal: RedPortal/Portal3D not found")
	else:
		portal_3d.exit_portal = exit_portal

	# Get the player
	player = $"../Player"
	if player == null:
		push_error("BluePortal: Player not found")

	# Get the player camera
	player_camera = player.camera
	if player_camera == null:
		push_error("BluePortal: Player Camera3D not found")
	else:
		portal_3d.player_camera = player_camera

	# Ensure cameras are set up after linking
	if portal_3d.exit_portal != null and portal_3d.player_camera != null:
		#portal_3d.activate()
		
		# Apply the Portal 2-like material after activation
		_apply_portal_material()
	else:
		push_error("BluePortal: BluePortal not activated.")

	# Ensure the player is on collision layer 16
	player.set_collision_layer_value(16, true)
	player.set_collision_mask_value(16, true)


func _apply_portal_material():
	# Wait a frame to ensure Portal3D has set up its material
	await get_tree().process_frame
	
	# Get the portal mesh and apply our custom material
	var portal_mesh = portal_3d.portal_mesh
	if portal_mesh != null:
		# Create a duplicate of our material so we can modify it independently
		var material = BLUE_PORTAL_MATERIAL.duplicate()
		portal_mesh.material_override = material
		
		# If the portal viewport is ready, connect it
		if portal_3d.portal_viewport != null:
			material.set_shader_parameter("albedo", portal_3d.portal_viewport.get_texture())
		else:
			# If not ready yet, wait and try again
			await get_tree().process_frame
			if portal_3d.portal_viewport != null:
				material.set_shader_parameter("albedo", portal_3d.portal_viewport.get_texture())
