extends Node3D

var player: CharacterBody3D

@onready var initial_parent = get_parent()
@onready var initial_rotation = global_rotation
@onready var initial_position = global_position


func _input(_event: InputEvent) -> void:
	if player:
		# (D-Pad Down) /[Q] _just_pressed_ -> Drop _this_node
		if Input.is_action_just_pressed(player.controls.button_13):
			_on_player_detection_body_exited(player)
			return


func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player = body
		if not player.is_skateboarding:
			reparent(player.visuals, true)
			position = Vector3(0.0, 0.0, 0.0)
			rotation = Vector3(0.0, deg_to_rad(90.0), 0.0)
			# Start "skateboarding"
			player.base_state.transition_state(player.current_state, States.State.SKATEBOARDING)
			return


func _on_player_detection_body_exited(body: Node3D) -> void:
	if body == player:
		player.base_state.transition_state(player.current_state, States.State.STANDING)
		player = null
		reparent(initial_parent)
		global_position = initial_position
		global_rotation = initial_rotation
