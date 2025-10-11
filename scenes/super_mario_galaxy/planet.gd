extends StaticBody3D


func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		body.gravitating_towards = self


func _on_area_3d_body_exited(body):
	if body is CharacterBody3D:
		body.gravitating_towards = null
