extends VehicleBody3D

@export var max_steer = 0.9
@export var engine_power = 300
@export var camera_auto_follow_enabled: bool = true
@export var camera_auto_follow_speed: float = 8.0
@export var camera_auto_follow_delay: float = 0.5

var player: CharacterBody3D
var _time_since_yaw_input: float = 0.0

@onready var driver_seat: Marker3D = $DriverSeat


## Called when there is an input event.
func _input(event) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	if player:
		# Ⓧ/[E] press to drive vehicle - Enter vehicle
		if event.is_action_pressed(player.controls.button_2) \
		and not player.is_driving:
			# Check for a collision with the raycast
			if player.camera.ray_cast.is_colliding():
				# Get the collision object
				var collider = player.camera.ray_cast.get_collider()
				# Check if the collider is a VehicleBody3D
				if collider is VehicleBody3D:
					# Start "driving"
					player.base_state.transition_state(player.current_state, States.State.DRIVING)
					return

		# While driving in third-person, apply free-look yaw via mouse motion
		if player.is_driving \
		and event is InputEventMouseMotion \
		and player.camera \
		and player.camera.perspective == player.camera.Perspective.THIRD_PERSON:
			var yaw_delta_deg: float = -event.relative.x * player.camera.look_sensitivity_mouse
			player.camera_mount.rotation.y += deg_to_rad(yaw_delta_deg)
			_time_since_yaw_input = 0.0


func _physics_process(_delta: float) -> void:
	if player:
		if player.is_driving:
			var steer_input = 0.0
			var throttle_input = 0.0
			if Input.is_action_pressed(player.controls.move_left):
				steer_input += 1.0
			if Input.is_action_pressed(player.controls.move_right):
				steer_input -= 1.0
			if Input.is_action_pressed(player.controls.move_up):
				throttle_input += 1.0
			if Input.is_action_pressed(player.controls.move_down):
				throttle_input -= 1.0
			steering = steer_input * max_steer
			engine_force = throttle_input * engine_power
			# Move the player to the vehicle's driver seat position
			player.global_position = driver_seat.global_position
			player.visuals.global_rotation = driver_seat.global_rotation


func _process(delta: float) -> void:
	if player and player.is_driving and player.camera:
		# Advance timer while in third-person
		if player.camera.perspective == player.camera.Perspective.THIRD_PERSON:
			_time_since_yaw_input += delta
			# Auto recentre after delay with smooth lerp
			if camera_auto_follow_enabled and _time_since_yaw_input >= camera_auto_follow_delay:
				var t: float = clamp(camera_auto_follow_speed * delta, 0.0, 1.0)
				var player_fwd: Vector3 = -player.global_transform.basis.z
				var vehicle_fwd: Vector3 = -player.visuals.global_transform.basis.z
				var player_angle: float = atan2(player_fwd.x, player_fwd.z)
				var vehicle_angle: float = atan2(vehicle_fwd.x, vehicle_fwd.z)
				var desired_local_yaw: float = vehicle_angle - player_angle
				player.camera_mount.rotation.y = lerp_angle(player.camera_mount.rotation.y, desired_local_yaw, t)


func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player = body


func _on_player_detection_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		if not body.is_driving:
			player = null
