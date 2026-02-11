extends Node3D
## Rifle pickup that attaches to player's right hand.

var bone_attachment: BoneAttachment3D
var player: CharacterBody3D

@onready var initial_parent: Node = get_parent()
@onready var initial_rotation: Vector3 = global_rotation
@onready var initial_position: Vector3 = global_position


## Called when there is an input event.
func _input(_event: InputEvent) -> void:
	if player:
		# Do nothing if the "pause" menu is visible
		if player.pause.visible: return

		# (D-Pad Down) /[Q] _just_pressed_ -> Drop _this_ node
		if Input.is_action_just_pressed(Controls.BUTTON_13):
			player.is_holding_rifle = false
			player.is_aiming_rifle = false
			player.is_firing_rifle = false
			#player.set_meta("is_holding_rifle", false)
			player = null
			reparent(initial_parent)
			global_position = initial_position
			global_rotation = initial_rotation
			bone_attachment.queue_free()
			bone_attachment = null
			return


## Attach _this_ node to the player's right hand when they enter the detection area.
func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D \
	and body.is_in_group("Player") \
	and player == null:
		player = body
		player.is_holding_rifle = true 
		#player.set_meta("is_holding_rifle", true)
		bone_attachment = BoneAttachment3D.new()
		bone_attachment.bone_name = player.bone_name_right_hand
		player.skeleton().add_child(bone_attachment)
		call_deferred("_attach_to_bone")


## [Deferred] Attach _this_ node to the player's bone_attachment after the current frame, to avoid errors about modifying the scene tree during physics processing.
func _attach_to_bone() -> void:
	reparent(bone_attachment)
	global_position = bone_attachment.global_position
	global_rotation = bone_attachment.global_rotation


## Placeholder.
func _on_player_detection_body_exited(body: Node3D) -> void:
	if body == player:
		pass
