extends Node3D

var player: CharacterBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var initial_parent = get_parent()
@onready var initial_rotation = global_rotation
@onready var initial_position = global_position


func _input(event: InputEvent) -> void:
	if player:
		# Ⓧ /[X] _just_pressed_ -> Start "standing"
		if Input.is_action_just_pressed(player.controls.button_2):
			_on_player_detection_body_exited(player)
			return

		# 🅁1/[MB1] _pressed_ -> Start "reeling"
		if event.is_action_pressed(player.controls.button_5):
			# Check if the animation player is not already playing the appropriate animation
			if animation_player.current_animation != "Take 001":
				# Play the "reeling" animation
				animation_player.play("Take 001")


func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player = body
		player.is_fishing = true
		# Create a BoneAttachment to attach the fishing rod to the player's hand
		var bone_attachment = BoneAttachment3D.new()
		bone_attachment.bone_name = "LeftHand"
		player.visuals.get_node("Godette/Rig/GeneralSkeleton").add_child(bone_attachment)
		reparent(bone_attachment)
		global_position = bone_attachment.global_position
		global_rotation = bone_attachment.global_rotation


func _on_player_detection_body_exited(body: Node3D) -> void:
	if body == player:
		player.is_fishing = false
		player = null
		reparent(initial_parent)
		global_position = initial_position
		global_rotation = Vector3(
			deg_to_rad(20.0),
			deg_to_rad(-180.0),
			deg_to_rad(-71.0),
		)
