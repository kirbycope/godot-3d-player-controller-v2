extends Node3D
## Skateboard pickup that transitions player to skateboarding state.

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
			player.base_state.transition_state(player.current_state, States.State.STANDING)
			player = null
			reparent(initial_parent)
			global_position = initial_position
			global_rotation = initial_rotation
			return


func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D \
	and body.is_in_group("Player") \
	and player == null:
		player = body
		if not player.is_skateboarding:
			call_deferred("_attach_to_player")
			# Start "skateboarding"
			player.base_state.transition_state(player.current_state, States.State.SKATEBOARDING)
			return


## [Deferred] Attach _this_ node to the player after the current frame, to avoid errors about modifying the scene tree during physics processing.
func _attach_to_player() -> void:
	reparent(player.visuals, true)
	position = Vector3(0.0, 0.0, 0.0)
	rotation = Vector3(0.0, deg_to_rad(90.0), 0.0)


## Placeholder.
func _on_player_detection_body_exited(body: Node3D) -> void:
	if body == player:
		pass
