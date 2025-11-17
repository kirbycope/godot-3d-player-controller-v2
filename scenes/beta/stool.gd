extends Node3D
## Simple stool seat that lets the player sit.

var is_in_use := false
var player: CharacterBody3D


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	if player:
		if  not player.pause.visible:
			if event.is_action_pressed(player.controls.button_1) \
			and not player.is_sitting:
				player.global_position = $Seat.global_position
				player.global_position -= Vector3(0, 0.4, 0) # [Hack] Adjust player visuals
				player.base_state.transition_state(player.current_state, States.State.SITTING)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D \
	and body.is_in_group("Player") \
	and player == null:
		player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D \
	and body.is_in_group("Player"):
		player = null
