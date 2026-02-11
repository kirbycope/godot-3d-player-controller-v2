extends Node3D
## Fishing rod pickup that plays a reel animation.

var bone_attachment: BoneAttachment3D
var player: CharacterBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var initial_parent: Node = get_parent()
@onready var initial_rotation: Vector3 = global_rotation
@onready var initial_position: Vector3 = global_position


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	if player:
		# Do nothing if the "pause" menu is visible
		if player.pause.visible: return

		# (D-Pad Down) /[Q] _just_pressed_ -> Drop _this_ node
		if Input.is_action_just_pressed(Controls.BUTTON_13):
			player.is_holding_fishing_rod = false
			player.is_casting_fishing = false
			player.is_reeling_fishing = false
			#player.set_meta("is_holding_fishing_rod", false)
			player = null
			reparent(initial_parent)
			global_position = initial_position
			global_rotation = initial_rotation
			bone_attachment.queue_free()
			bone_attachment = null
			return

		# 🅁1/[MB1] _pressed_ -> Start "reeling"
		if event.is_action_pressed(Controls.BUTTON_5):
			# Check if the animation player is not already playing the appropriate animation
			if animation_player.current_animation != "Take 001":
				# Play the "reeling" animation
				animation_player.play("Take 001")


## Attach _this_ node to the player's bone_attachment when they enter the detection area.
func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D \
	and body.is_in_group("Player") \
	and player == null:
		player = body
		player.is_holding_fishing_rod = true
		#player.set_meta("is_holding_fishing_rod", true)
		bone_attachment = BoneAttachment3D.new()
		bone_attachment.bone_name = player.bone_name_left_hand
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
