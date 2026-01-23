@tool
extends Node3D

@onready var character: Node3D = $Character
@onready var player: Player = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if character:
		if character.top_level:
			if player.global_position != character.global_position:
				# Move the character to follow the player
				# Snap the character to the player's lateral position (relative to up_direction)
				# Interpolate the vertical position (for stair stepping smoothness)
				var diff = global_position - character.global_position
				var vertical_diff = diff.dot(player.up_direction) * player.up_direction
				var lateral_diff = diff - vertical_diff
				character.global_position += lateral_diff + vertical_diff * 20.0 * delta

			# Rotate the character to follow the visuals
			character.global_transform.basis = character.global_transform.basis.orthonormalized().slerp(global_transform.basis.orthonormalized(), 20.0 * delta)
