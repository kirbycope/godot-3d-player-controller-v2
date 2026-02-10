extends StaticBody3D

@export var is_moist: bool = false ## Is the dirt block moist?
@export var planted: StaticBody3D ## The plant placed on this block (if any)

var player: CharacterBody3D


func _ready() -> void:
	if is_moist:
		var material = $MeshInstance3D.get_active_material(0).duplicate()
		$MeshInstance3D.set_surface_override_material(0, material)
		material.albedo_color = Color8(123, 123, 123)


func _input(event: InputEvent) -> void:
	if player:
		# Do nothing if the "pause" menu is visible
		if player.pause.visible: return

		# Ⓧ/[E] _pressed_
		if event.is_action_pressed(Controls.BUTTON_2):
			# Use watering can
			if player.get_meta("is_holding_watering_can", false) \
			and not is_moist:
				player.animation_player_play_locked("Standing_Watering/mixamo_com")
				is_moist = true
				# Tween albedo color starting halfway through the animation
				var animation_length = player.animation_player_current_animation_length("Standing_Watering/mixamo_com")
				var material = $MeshInstance3D.get_active_material(0).duplicate()
				$MeshInstance3D.set_surface_override_material(0, material)
				var tween = get_tree().create_tween()
				tween.tween_property(
					material,
					"albedo_color",
					Color8(123, 123, 123),
					animation_length / 2.0
				)#.set_delay(animation_length / 2.0)
			# Plant seeds
			elif player.get_meta("is_holding_seeds", false) \
			and is_moist \
			and planted == null:
				var flat_target := Vector3(
					global_position.x,
					player.global_position.y,
					global_position.z,
				)
				player.look_at(flat_target, player.up_direction)
				player.animation_player_play_locked("Crouching_Planting/mixamo_com")
				await get_tree().create_timer(2.5).timeout
				var flower_red_scene := preload("res://scenes/level_3/blocks/flower_red.tscn")
				var flower_red_instance := flower_red_scene.instantiate()
				var top_position := global_transform.origin + Vector3(
					0,
					$CollisionShape3D.shape.size.y / 2.0,
					0,
				)
				flower_red_instance.global_transform.origin = top_position
				get_parent().add_child(flower_red_instance)
				flower_red_instance.block_below = self
				planted = flower_red_instance
				#queue_free()


## A helper function for interaction (called from the player).
func on_interact(caller) -> void:
	player = caller

	var ev := InputEventAction.new()
	ev.action = Controls.BUTTON_2
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
