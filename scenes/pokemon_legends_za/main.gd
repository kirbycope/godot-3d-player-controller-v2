extends Node3D

@onready var player = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.camera.lock_camera = false
	player.camera.lock_perspective = false
	player.camera.set_camera_perspective(player.camera.Perspective.THIRD_PERSON)
	player.enable_climbing = false
	player.enable_crawling = true
	player.enable_crouching = true
	player.enable_driving = false
	player.enable_double_jumping = false
	player.enable_flying = false
	player.enable_hanging = false
	player.enable_holding_objects = false
	player.enable_jumping = false
	player.enable_kicking = false
	player.enable_navigation = false
	player.enable_paragliding = false
	player.enable_punching = false
	player.enable_retical = false
	player.enable_rolling = false
	player.enable_sliding = false
	player.enable_sprinting = false
	player.enable_swimming = false
	player.lock_movement_x = false
	player.lock_movement_y = false
	player.lock_movement_z = false


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(player.controls.button_5):
		player.play_locked_animation("Standing_Throwing_Right/mixamo_com")
		await get_tree().create_timer(0.8).timeout
		var tennis_ball = $TennisBall.duplicate()
		tennis_ball.get_node("PlayerDetection").monitoring = false
		add_child(tennis_ball)
		tennis_ball.scale = Vector3.ONE
		var force_direction = -player.camera.global_transform.basis.z.normalized()
		var spawn_offset = player.up_direction * 1.5 + force_direction * 0.5
		tennis_ball.global_position = player.global_position + spawn_offset
		tennis_ball.apply_impulse(force_direction * 10.0, Vector3.ZERO)
		await get_tree().create_timer(0.1).timeout
		tennis_ball.get_node("PlayerDetection").monitoring = true
