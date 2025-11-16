extends RigidBody3D
## A buoyant crate that floats and drags in water.

@export var buoyancy_force := 20.0 ## Upward force when submerged
@export var water_drag := 0.5 ## Linear resistance in water
@export var water_angular_drag := 0.5 ## Rotational resistance in water

var in_water := false
var height: float
var water_area: Area3D = null
var water_level := 0.0

func _ready() -> void:
	height = get_node("CollisionShape3D").shape.size.y


func _physics_process(delta: float) -> void:
	if in_water:
		apply_buoyancy(delta)


func apply_buoyancy(delta: float) -> void:
	var y_pos := global_position.y
	if water_level < (y_pos + height):
		# Apply upward buoyancy force
		var buoyancy := Vector3.UP * buoyancy_force
		apply_central_force(buoyancy)

		# Apply water drag to slow down movement
		linear_velocity *= (1.0 - water_drag * delta)
		angular_velocity *= (1.0 - water_angular_drag * delta)


func _on_water_detection_area_entered(area: Area3D) -> void:
	# Check if this is your water area (you can use groups or naming)
	if area.is_in_group("water"):
		in_water = true
		water_area = area
		var shape = water_area.get_node("CollisionShape3D").shape
		water_level = water_area.global_position.y + shape.size.y/2

func _on_water_detection_area_exited(area: Area3D) -> void:
	if area == water_area:
		in_water = false
		water_area = null
