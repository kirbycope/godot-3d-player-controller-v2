extends Node3D

@onready var animation_player = $AnimationPlayer


func _on_area_3d_body_entered(body):
	if body is CharacterBody3D \
	or body is RigidBody3D:
		animation_player.play("press")


func _on_area_3d_body_exited(body):
	if body is CharacterBody3D \
	or body is RigidBody3D:
		animation_player.play_backwards("press")
