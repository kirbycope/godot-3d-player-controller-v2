extends CSGBox3D
## Climbing slab that moves the player along an incline and aligns facing.

const CLIMBING_ANIMATION = "Climbing_Incline_Steep/mixamo_com"
const CLIMBING_CROUCHING = "Crouching/mixamo_com"
const STANDING_ANIMATION = "Standing/mixamo_com"

var timer: Timer

@onready var player: CharacterBody3D


func _input(_event: InputEvent) -> void:
	if player and not player.is_animation_locked:
		# Check if player is providing movement input
		if player.input_direction != Vector2.ZERO:
			# Convert player's input direction to world space 3D direction
			var input_dir_3d: Vector3 = player.transform.basis * Vector3(player.input_direction.x, 0, player.input_direction.y)
			input_dir_3d = input_dir_3d.normalized()
			
			# Check if player is facing the wall
			if player.ray_cast_middle.get_collider() == self:
				var collision_normal = player.ray_cast_middle.get_collision_normal()
				var wall_direction = -collision_normal
				
				# Check if player's movement direction aligns with the wall direction
				# (dot product > 0.5 means roughly facing the wall, allowing ~60 degree cone)
				if input_dir_3d.dot(wall_direction) > 0.5:
					_face_wall()
					var animation_length = player.play_locked_animation(CLIMBING_ANIMATION)
					var tween = get_tree().create_tween()
					tween.tween_property(player, "global_position", $EndPoint.global_position, animation_length)
					tween.finished.connect(func(): 
						if player:
							player.animation_player.play(CLIMBING_CROUCHING, 0.0)
							tween.queue_free()
					)

func _face_wall() -> void:
	if player:
		# Get the collision normal
		var collision_normal = player.ray_cast_middle.get_collision_normal()

		# Calculate the wall direction
		var wall_direction = -collision_normal

		# Make the player face the wall while keeping upright (flatten onto plane perpendicular to up)
		wall_direction = (wall_direction - player.up_direction * wall_direction.dot(player.up_direction)).normalized()
		if wall_direction.length() > 0.0 and player.position != player.position + wall_direction:
			player.visuals.look_at(player.position + wall_direction, player.up_direction)

func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player = body


func _on_player_detection_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player = null
