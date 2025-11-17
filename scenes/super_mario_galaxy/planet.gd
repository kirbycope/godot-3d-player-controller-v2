extends StaticBody3D
## Planet that applies local gravity to bodies.


func _on_area_3d_body_entered(body: Node) -> void:
	if body is CharacterBody3D \
	and body.is_in_group("Player"):
		body.gravitating_towards = self


func _on_area_3d_body_exited(body: Node) -> void:
	if body is CharacterBody3D \
	and body.is_in_group("Player"):
		body.gravitating_towards = null
