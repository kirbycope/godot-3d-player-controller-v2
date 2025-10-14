extends Node3D

@onready var player = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		print("Player is on the button.")


func _on_area_3d_body_exited(body):
	if body is CharacterBody3D:
		print("Player moved off of the button.")


func _on_pedestal_area_3d_body_entered(body):
	if body is CharacterBody3D:
			print("Player is near the button.")


func _on_pedestal_area_3d_body_exited(body):
	if body is CharacterBody3D:
			print("Player moved away from the button.")
