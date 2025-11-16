extends Node3D
## Weighted button that responds to bodies pressing it.

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_area_3d_body_entered(body: Node) -> void:
	if body is CharacterBody3D \
	or body is RigidBody3D:
		animation_player.play("press")


func _on_area_3d_body_exited(body: Node) -> void:
	if body is CharacterBody3D \
	or body is RigidBody3D:
		animation_player.play_backwards("press")
