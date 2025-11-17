extends RigidBody3D
## Tennis ball pickup that attaches to player's hand.

var bone_attachment: BoneAttachment3D
var player: CharacterBody3D

@onready var initial_parent: Node = get_parent()
@onready var initial_rotation: Vector3 = global_rotation
@onready var initial_position: Vector3 = global_position


func _input(_event: InputEvent) -> void:
	if player:
		# Do nothing if the "pause" menu is visible
		if player.pause.visible: return

		# (D-Pad Down) /[Q] _just_pressed_ -> Drop _this_node
		if Input.is_action_just_pressed(player.controls.button_13):
			player.is_holding_right = false
			player.is_throwing_right = false
			player = null
			collision_layer = 1
			reparent(initial_parent)
			global_position = initial_position
			global_rotation = initial_rotation
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			# optionally stop simulation
			#sleeping = true
			bone_attachment.queue_free()
			bone_attachment = null
			return


func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D \
	and body.is_in_group("Player") \
	and player == null:
		player = body
		player.is_holding_right = true
		bone_attachment = BoneAttachment3D.new()
		bone_attachment.bone_name = player.bone_name_right_hand
		player.skeleton.add_child(bone_attachment)
		reparent(bone_attachment)
		global_position = bone_attachment.global_position
		global_rotation = bone_attachment.global_rotation
		collision_layer = 2


func _on_player_detection_body_exited(body: Node3D) -> void:
	if body == player:
		pass
