extends StaticBody3D

var player: CharacterBody3D


func _input(event: InputEvent) -> void:
	if player:
		# Do nothing if the "pause" menu is visible
		if player.pause.visible: return

		# Ⓧ/[E] _pressed_ -> Convert `grass` to `dirt` using hoe
		if event.is_action_pressed(player.controls.button_2):
			if player.get_meta("is_holding_hoe"):
				var length = player.play_locked_animation("Standing_Digging/mixamo_com", 3.0)
				await get_tree().create_timer(3.0).timeout
				var dirt_block_scene := preload("res://scenes/level_3/blocks/dirt_block.tscn")
				var dirt_block_instance := dirt_block_scene.instantiate()
				dirt_block_instance.global_transform = global_transform
				get_parent().add_child(dirt_block_instance)
				queue_free()


## A helper function for interaction (called from the player).
func on_interact(caller) -> void:
	player = caller

	var ev := InputEventAction.new()
	ev.action = player.controls.button_2
	ev.pressed = true
	_input(ev)

	player = null


func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D \
	and body.is_in_group("Player") \
	and player == null:
		player = body


func _on_player_detection_body_exited(body: Node3D) -> void:
	if body == player:
		player = null
