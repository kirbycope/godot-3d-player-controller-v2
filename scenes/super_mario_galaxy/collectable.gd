extends RigidBody3D

const OPEN_001 = preload("uid://5eewm7hxkjq")
const OPEN_002 = preload("uid://dpmvor2ujenmj")
const OPEN_003 = preload("uid://8spro6ern7km")
const OPEN_004 = preload("uid://pm62v6e87r8l")

@onready var audio_stream_player_3d = $AudioStreamPlayer3D
@onready var mesh_instance_3d = $MeshInstance3D
@onready var mesh_instance_3d_2 = $MeshInstance3D2

var is_being_collected = false
var pickup_tween: Tween
var pickup_start_position: Vector3
var pickup_duration := 0.8
var pickup_progress := 0.0


## Called when the node enters the scene tree for the first time.
func _ready():
	var random_color = Color(randf(), randf(), randf(), 1.0)
	var material = StandardMaterial3D.new()
	material.albedo_color = random_color
	mesh_instance_3d.material_override = material
	mesh_instance_3d_2.material_override = material.duplicate()


func _on_area_3d_mouse_entered():
	if is_being_collected:
		return

	is_being_collected = true
	pickup_collectable()
	play_pickup_sound()


func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		if is_being_collected:
			return

		is_being_collected = true
		pickup_collectable()
		play_pickup_sound()


func pickup_collectable():
	# Find the camera in the scene
	var camera = get_viewport().get_camera_3d()
	if not camera:
		queue_free()
		return

	# Disable physics so it can move freely
	freeze = true

	# Store start position
	pickup_start_position = global_position

	# Create a tween for smooth movement
	pickup_tween = create_tween()
	pickup_tween.set_parallel(true)

	# Tween a progress value from 0 to 1
	pickup_tween.tween_method(_update_pickup_motion, 0.0, 1.0, pickup_duration)
	pickup_tween.tween_method(_rotate_while_moving, 0.0, 720.0, pickup_duration)
	pickup_tween.tween_property(self, "scale", Vector3(0.1, 0.1, 0.1), pickup_duration)
	pickup_tween.finished.connect(queue_free)


func _update_pickup_motion(progress: float):
	pickup_progress = progress
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	var camera_forward = -camera.global_transform.basis.z
	var target_position = camera.global_position + camera_forward * 0.5
	# Interpolate between start and current camera position
	global_position = pickup_start_position.lerp(target_position, progress)


func _rotate_while_moving(degrees: float):
	# Rotate the object while it's flying towards the camera
	rotation_degrees = Vector3(degrees, degrees * 0.7, degrees * 1.3)


func play_pickup_sound():
	var sound_options = [OPEN_001, OPEN_002, OPEN_003, OPEN_004]
	var chosen_sound = sound_options[randi() % sound_options.size()]
	audio_stream_player_3d.stream = chosen_sound
	audio_stream_player_3d.play()
