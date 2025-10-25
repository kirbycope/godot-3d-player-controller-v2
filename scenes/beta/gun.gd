extends Node3D

var bone_attachment: BoneAttachment3D
var player: CharacterBody3D

@onready var initial_parent = get_parent()
@onready var initial_rotation = global_rotation
@onready var initial_position = global_position


func _input(_event: InputEvent) -> void:
	if player:
		# Do nothing if the "pause" menu is visible
		if player.pause.visible: return

		# (D-Pad Down) /[Q] _just_pressed_ -> Drop _this_node
		if Input.is_action_just_pressed(player.controls.button_13):
			_on_player_detection_body_exited(player)
			return


## Attach _this_ node to the player's right hand when they enter the detection area.
func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player = body
		player.is_holding_rifle = true 
		bone_attachment = BoneAttachment3D.new()
		bone_attachment.bone_name = player.bone_name_right_hand
		player.skeleton.add_child(bone_attachment)
		reparent(bone_attachment)
		global_position = bone_attachment.global_position
		global_rotation = bone_attachment.global_rotation


## Detach _this_ node from the player when they exit the detection area.
func _on_player_detection_body_exited(body: Node3D) -> void:
	if body == player:
		player.is_holding_rifle = false
		player.is_aiming_rifle = false
		player.is_firing_rifle = false
		player = null
		reparent(initial_parent)
		global_position = initial_position
		global_rotation = initial_rotation
		bone_attachment.queue_free()
		bone_attachment = null
