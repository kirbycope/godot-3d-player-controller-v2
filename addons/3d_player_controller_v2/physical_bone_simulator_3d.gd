extends PhysicalBoneSimulator3D


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent = get_parent()
	for child in parent.get_children():
		# Ignore self to prevent infinite loop
		if child == self:
			continue
		# Look for the `%GeneralSkeleton` node among siblings
		var general_skeleton = child.get_node_or_null("%GeneralSkeleton")
		if general_skeleton != null:
			call_deferred("_deferred_setup", general_skeleton)
			break


# Reparents _this_ PhysicalBoneSimulator3D to the `%GeneralSkeleton`
func _deferred_setup(general_skeleton: Node) -> void:
	reparent(general_skeleton)
