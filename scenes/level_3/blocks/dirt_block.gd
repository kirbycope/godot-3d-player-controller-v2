extends StaticBody3D

@export var is_moist: bool = false ## Is the dirt block moist?

var player: CharacterBody3D


func _input(event: InputEvent) -> void:
	if player:
		# Do nothing if the "pause" menu is visible
		if player.pause.visible: return

		# Ⓧ/[E] _pressed_
		if event.is_action_pressed(player.controls.button_2):
			if player.get_meta("is_holding_scythe"):
				player.play_locked_animation("Standing_Harvesting/mixamo_com", 1.0)
			elif player.get_meta("is_holding_watering_can") \
			and not is_moist:
				player.play_locked_animation("Standing_Watering/mixamo_com")
				is_moist = true
				# Tween albedo color starting halfway through the animation
				var animation_length = player.animation_player.current_animation_length
				var material = $MeshInstance3D.get_active_material(0)
				var tween = get_tree().create_tween()
				tween.tween_property(
					material,
					"albedo_color",
					Color8(123, 123, 123),
					animation_length / 2.0
				)#.set_delay(animation_length / 2.0)
				return


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
