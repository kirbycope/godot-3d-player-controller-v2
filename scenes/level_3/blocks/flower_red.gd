extends StaticBody3D

var block_below: StaticBody3D # This plant requires a block to be placed below it
var player: CharacterBody3D


func _input(event: InputEvent) -> void:
	if player:
		# Do nothing if the "pause" menu is visible
		if player.pause.visible: return

		# Ⓧ/[E] _pressed_ -> Swing scythe
		if event.is_action_pressed(player.controls.button_2):
			if player.get_meta("is_holding_scythe", false):
				player.play_locked_animation("Standing_Harvesting/mixamo_com", 1.0)
				if block_below:
					block_below.planted = null
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
