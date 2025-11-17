@tool
extends ArrayMesh
class_name PortalBoxMesh

## Inverted box with a flipped front side
##
## This mesh class generates a mesh similar to [BoxMesh]. However, its sides are all facing 
## [i]inwards[/i], except for the fron side, which is facing outwards. The origin point of this 
## mesh is in the middle of its front face, instead of in the center of its volume (like you'd 
## expect with a box).[br]
## It is a special mesh built for portal surfaces. The front face provides a nice flat surface and 
## the other sides try to reduce clipping issues when traveling through portals. See [Portal3D]

@export var size: Vector3 = Vector3(1, 1, 1):
	set(v):
		size = v
		generate_portal_mesh()

func _init() -> void:
	if Engine.is_editor_hint():
		generate_portal_mesh()

func generate_portal_mesh() -> void:
	var _start_time: int = Time.get_ticks_usec()
	clear_surfaces() # Reset

	var surface_array: Array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	var verts: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()

	# Just to save some chars
	var w: float = size.x / 2
	var h: float = size.y / 2
	var depth: Vector3 = Vector3(0, 0, -size.z)

	# Outside rect
	var TOP_LEFT: Vector3 = Vector3(-w, h, 0)
	var TOP_RIGHT: Vector3 = Vector3(w, h, 0)
	var BOTTOM_LEFT: Vector3 = Vector3(-w, -h, 0)
	var BOTTOM_RIGHT: Vector3 = Vector3(w, -h, 0)
	

	verts.append_array([
	TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT,
	TOP_LEFT + depth, TOP_RIGHT + depth, BOTTOM_LEFT + depth, BOTTOM_RIGHT + depth,
	])
	uvs.append_array([
	Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), # Front UVs
	Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), # Back UVs (the same)
	])

	# We are going for a flat-surface look here. Portals should be unshaded anyways.
	normals.append_array([
	Vector3.BACK, Vector3.BACK, Vector3.BACK, Vector3.BACK,
	Vector3.BACK, Vector3.BACK, Vector3.BACK, Vector3.BACK
	])

	# 0 ----------- 1
	# | \         / |
	# |  4-------5  |
	# |  |       |  |
	# |  |       |  |
	# |  6-------7  |
	# | /         \ |
	# 2 ----------- 3

	# Triangles are clockwise!

	indices.append_array([
		0, 1, 4,
		4, 1, 5, # Top section done
		1, 3, 5,
		5, 3, 7, # right section done
		3, 2, 7,
		7, 2, 6, # bottom section done
		2, 0, 6,
		6, 0, 4, # left section done
	
		4, 5, 6,
		6, 5, 7, # back section done
		
		0, 1, 2,
		2, 1, 3, # front section done
	])

	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
