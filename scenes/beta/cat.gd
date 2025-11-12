extends Node3D


var player: CharacterBody3D

@onready var animation_player = $Visuals/AnimationPlayer


## Called when there is an input event.
func _input(event) -> void:
	if player:
		# Do nothing if the "pause" menu is visible
		if player.pause.visible: return

		# Ⓧ/[E] _pressed_ -> Start "petting" animation
		if event.is_action_pressed(player.controls.button_2):
			var flat_target := Vector3(
				global_position.x,
				player.global_position.y,
				global_position.z,
			)
			player.look_at(flat_target, player.up_direction)
			if animation_player.current_animation != "Caress_idle":
				animation_player.play("Caress_idle")
				animation_player.connect("animation_finished", _on_cat_animation_finished)
			player.play_locked_animation("Standing_Petting_Animal_High/mixamo_com")


func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		player = body


func _on_area_3d_body_exited(body):
	if body is CharacterBody3D:
		player = null


func _on_cat_animation_finished(anim_name: String) -> void:
	if anim_name == "Caress_idle":
		animation_player.play("Idle_1")
