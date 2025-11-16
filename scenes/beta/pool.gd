extends CSGBox3D
## Swimming pool volume that switches player state to swimming.

var player: CharacterBody3D


func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D \
	and player == null:
		player = body
		player.is_swimming_in = self
		# Move player to surface of the pool
		player.global_position.y = global_position.y + (player.collision_height * 0.6) + 0.1
		# Start "swimming"
		player.base_state.transition_state(player.current_state, States.State.SWIMMING)
		return


func _on_player_detection_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player.base_state.transition_state(player.current_state, States.State.STANDING)
		player.is_swimming_in = null
		player = null
