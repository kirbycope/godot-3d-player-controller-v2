extends VehicleBody3D

@export var max_steer = 0.9
@export var engine_power = 300

var player: CharacterBody3D

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


func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player = body


func _on_player_detection_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		if not body.is_driving:
			player = null
