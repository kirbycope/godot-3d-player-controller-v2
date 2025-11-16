extends Node3D
## Pedestal button that triggers when the player interacts.

var player: CharacterBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	if player:
		# Do nothing if the "pause" menu is visible
		if player.pause.visible: return

		# Ⓧ/[E] _pressed_ -> Start "pressing" animation
		if event.is_action_pressed(player.controls.button_2):
			if player.camera.ray_cast.is_colliding():
				var collider = player.camera.ray_cast.get_collider()
				if collider.get_parent() == self:
					if animation_player.current_animation != "press":
						animation_player.play("press")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player = null
