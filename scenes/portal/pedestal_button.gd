extends Node3D

var player: CharacterBody3D

@onready var animation_player = $AnimationPlayer


## Called when there is an input event.
func _input(event) -> void:
	if player:
		# Do nothing if the "pause" menu is visible
		if player.pause.visible: return

		if event.is_action_pressed(player.controls.button_2):
			if player.camera.ray_cast.is_colliding():
				var collider = player.camera.ray_cast.get_collider()
				if collider.get_parent() == self:
					if animation_player.current_animation != "press":
						animation_player.play("press")


func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		player = body


func _on_area_3d_body_exited(body):
	if body is CharacterBody3D:
		player = null
