extends Node3D

@onready var animation_player: AnimationPlayer = $Visuals/AnimationPlayer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@export var move_speed := 2.0 ## Speed at which the duck moves
@export var follow_distance := 2.0 ## Distance to maintain from the player
@export var max_follow_distance := 5.0 ## Maximum distance before duck stops following

var player: CharacterBody3D


func _ready() -> void:
	# Wait for the navigation map to be ready
	call_deferred("_setup_navigation")


func _setup_navigation() -> void:
	# Make sure to wait for the first physics frame for the NavigationServer to sync
	await get_tree().physics_frame
	navigation_agent_3d.path_desired_distance = 0.5
	navigation_agent_3d.target_desired_distance = follow_distance


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	play_animation()


func _physics_process(_delta: float) -> void:
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# Stop following if player gets too far away
		if distance_to_player > max_follow_distance:
			player = null
			return
		
		# Only follow if beyond the follow distance
		if distance_to_player > follow_distance:
			navigation_agent_3d.target_position = player.global_position
			if navigation_agent_3d.is_navigation_finished() == false:
				# Get the next position to move towards
				var next_path_position: Vector3 = navigation_agent_3d.get_next_path_position()
				var direction: Vector3 = global_position.direction_to(next_path_position)

				# Move the duck
				var new_position = global_position + direction * move_speed * _delta
				global_position = new_position

				# Rotate the duck to face the direction of movement
				if direction.length() > 0.01:
					var target_rotation = atan2(direction.x, direction.z)
					rotation.y = lerp_angle(rotation.y, target_rotation, 10.0 * _delta)


func play_animation() -> void:
	if player \
	and not navigation_agent_3d.is_navigation_finished():
		animation_player.play_section("Armature|White Duck_TempMotion|White Duck_TempMotion", 9.7, 10.8) # Walk
	else:
		animation_player.play_section("Armature|White Duck_TempMotion|White Duck_TempMotion", 0.0, 9.6) # Idle


func _on_player_detection_body_entered(body):
	if body is CharacterBody3D \
	and body.is_in_group("Player"):
		player = body


func _on_player_detection_body_exited(body):
	if body is CharacterBody3D \
	and body.is_in_group("Player"):
		pass
