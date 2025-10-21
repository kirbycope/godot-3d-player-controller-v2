extends Node3D

var player: CharacterBody3D


func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player = body
		if not player.is_skateboarding:
			reparent(player.visuals)
			position = Vector3(0.0, 0.0, 0.0)
			rotation = Vector3(0.0, deg_to_rad(90.0), 0.0)
			# Start "skateboarding"
			player.base_state.transition_state(player.current_state, States.State.SKATEBOARDING)
			return


func _on_player_detection_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		body = null
