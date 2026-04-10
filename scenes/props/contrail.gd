extends MeshInstance3D

@export var from_width: float = 0.05
@export var to_width: float = 0.0
@export var lifespan: float = 1.0
@export var start_color: Color = Color(1, 1, 1, 0.1)
@export var end_color: Color = Color(1, 1, 1, 0)

var _points = []
var _ages = []

func _ready():
	mesh = ImmediateMesh.new()

func _process(delta: float):
	_points.append(global_position)
	_ages.append(0.0)
	
	var i = 0
	while i < _ages.size():
		_ages[i] += delta
		if _ages[i] > lifespan:
			_ages.remove_at(i)
			_points.remove_at(i)
			continue
		i += 1
		
	mesh.clear_surfaces()
	if _points.size() < 2: return
	
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	var cam = get_viewport().get_camera_3d()
	var cam_pos = cam.global_position if cam else Vector3.ZERO
	
	for iter_idx in range(_points.size()):
		var p_idx = _points.size() - 1 - iter_idx
		var t = _ages[p_idx] / lifespan
		var width = lerp(from_width, to_width, t)
		var c = start_color.lerp(end_color, t)
		var p = _points[p_idx]
		
		var to_cam = (cam_pos - p).normalized()
		if to_cam == Vector3.ZERO: to_cam = Vector3.UP
			
		var dir = Vector3.UP
		if p_idx > 0:
			dir = (_points[p_idx-1] - p).normalized()
		elif p_idx < _points.size() - 1:
			dir = (p - _points[p_idx+1]).normalized()
			
		if dir == Vector3.ZERO: dir = Vector3.FORWARD
			
		var side = dir.cross(to_cam).normalized() * (width * 0.5)
		
		mesh.surface_set_color(c)
		mesh.surface_add_vertex(to_local(p + side))
		mesh.surface_set_color(c)
		mesh.surface_add_vertex(to_local(p - side))
		
	mesh.surface_end()
