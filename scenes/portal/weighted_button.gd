extends Node3D
## Weighted button that responds to bodies pressing it.

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var pressed := false

func _on_area_3d_body_entered(body: Node) -> void:
	if body is CharacterBody3D \
	or body is RigidBody3D:
		animation_player.play("press")
		pressed = true


func _on_area_3d_body_exited(body: Node) -> void:
	if body is CharacterBody3D \
	or body is RigidBody3D:
		animation_player.play_backwards("press")
		pressed = false
		$"../BluePortal/Portal3D".deactivate()
		$"../RedPortal/Portal3D".deactivate()
