class_name BaseState
extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Ⓐ/[Space] _pressed_ (while airborne) -> Start "climbing"
	if player.enable_climbing:
		if Input.is_action_just_pressed(player.controls.button_0) \
		and (player.is_falling or player.is_jumping) \
		and not player.is_climbing:
			# Check if the player is facing a surface
			if player.ray_cast_high.is_colliding():
				# Get the collision object
				var collision_object = player.ray_cast_high.get_collider()
				# Check if the collision object is "climbable"
				if not collision_object is CharacterBody3D \
				and not collision_object is SoftBody3D:
					# Start "climbing"
					transition_state(player.current_state, States.State.CLIMBING)
					return

	# Ⓐ/[Space] _pressed_ (while airborne) -> Start "double-jumping"
	if player.enable_double_jumping:
		if Input.is_action_just_pressed(player.controls.button_0) \
		and (player.is_falling or player.is_jumping) \
		and not player.is_double_jumping:
			player.is_double_jumping = true
			# Start "jumping"
			transition_state(player.current_state, States.State.JUMPING)
			return

	# Ⓐ/[Space] _pressed_ (while airborne) -> Start "flying"
	if player.enable_flying:
		if Input.is_action_just_pressed(player.controls.button_0) \
		and (player.is_falling or player.is_jumping) \
		and not player.is_flying:
			# Start "flying"
			transition_state(player.current_state, States.State.FLYING)
			return

	# Ⓐ/[Space] _pressed_ (while airborne) -> Start "paragliding"
	if player.enable_paragliding:
		if Input.is_action_just_pressed(player.controls.button_0) \
		and (player.is_falling or player.is_jumping) \
		and not player.is_paragliding:
			# Start "paragliding"
			transition_state(player.current_state, States.State.PARAGLIDING)
			return

	# Ⓨ/[Ctrl] _pressed_ -> Stop "climbing"/"hanging/paragliding" and start "falling"
	if player.is_climbing \
	or player.is_hanging \
	or player.is_paragliding:
		if Input.is_action_just_pressed(player.controls.button_3):
			# Start "falling"
			transition_state(player.current_state, States.State.FALLING)
			return

	# Ⓑ/[shift] _pressed_ -> Start "sprinting"
	if player.enable_sprinting:
		if Input.is_action_just_pressed(player.controls.button_1) \
		and not player.is_climbing \
		and not player.is_driving \
		and not player.is_flying \
		and not player.is_hanging \
		and not player.is_paragliding \
		and not player.is_sprinting \
		and not player.is_swimming \
		and player.is_on_floor():
			transition_state(player.current_state, States.State.SPRINTING)
			return


## Called once on each physics tick, and allows Nodes to synchronize their logic with physics ticks.
func _physics_process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if the player is looking at a grabable ledge -> Start "hanging"
	if player.enable_hanging:
		if not player.is_flying \
		and not player.is_hanging \
		and not player.ray_cast_top.is_colliding() \
		and player.ray_cast_high.is_colliding():
			# Start "hanging"
			transition_state(player.current_state, States.State.HANGING)
			return

	# Check if the player is not on a floor -> Start "falling"
	if not player.is_on_floor() \
	and not player.is_climbing \
	and not player.is_flying \
	and not player.is_hanging \
	and not player.is_jumping \
	and not player.is_paragliding \
	and not player.is_punching_left \
	and not player.is_punching_right:
		transition_state(player.current_state, States.State.FALLING)
		return

	# Change state based on velocity
	if not player.is_climbing \
	and not player.is_crawling \
	and not player.is_crouching \
	and not player.is_driving \
	and not player.is_flying \
	and not player.is_hanging \
	and not player.is_paragliding \
	and not player.is_punching_left \
	and not player.is_punching_right \
	and not player.is_swimming:

		# Reset double-jump flag when on the ground
		if player.is_on_floor():
			player.is_double_jumping = false

		# Check if the player is not moving -> Start "standing"
		if abs(player.velocity).length() < 0.2 \
		and abs(player.virtual_velocity).length() < 0.2 \
		and not player.is_crouching:
			transition_state(player.current_state, States.State.STANDING)
			return

		# Check if the player's current speed is slower than or equal to "walking" speed -> Start "walking"
		elif 0.0 < player.speed_current \
		and player.speed_current <= player.speed_walking:
			transition_state(player.current_state, States.State.WALKING)
			return

		# Check if the player speed is faster than "walking" but slower than or equal to "running" -> Start "running"
		elif (player.speed_walking < player.speed_current) \
		and (player.speed_current <= player.speed_running):
			transition_state(player.current_state, States.State.RUNNING)
			return


## Returns the string name of a state.
func get_state_name(state: States.State) -> String:
	# Return the state name with the first letter capitalized
	return States.State.keys()[state].capitalize().replace(" ", "")


## Provides movement logic for climbing and hanging states; which are mostly skipped in player._physics_process().
func move_player() -> void:
	# Get the collision normal (wall outward direction)
	var collision_normal_normalized: Vector3 = player.ray_cast_high.get_collision_normal().normalized()

	# Build an orthonormal basis for the wall plane using player's up and wall normal
	# Remove any component of up along the normal to get the wall-up (shimmy) axis
	var wall_up: Vector3 = (player.up_direction - collision_normal_normalized * player.up_direction.dot(collision_normal_normalized)).normalized()
	# Right axis along the wall (perpendicular to wall_up and normal)
	var wall_right: Vector3 = wall_up.cross(collision_normal_normalized).normalized()

	# Gather inputs mapped onto wall axies
	var move_direction: Vector3 = Vector3.ZERO
	if Input.is_action_pressed(player.controls.move_left):
		move_direction -= wall_right
	if Input.is_action_pressed(player.controls.move_right):
		move_direction += wall_right
	# only apply vertical movement if climbing
	if player.is_climbing:
		if Input.is_action_pressed(player.controls.move_up):
			move_direction += wall_up
		if Input.is_action_pressed(player.controls.move_down):
			move_direction -= wall_up

	# Normalize to keep diagonal speed consistent
	if move_direction.length() > 0.0:
		move_direction = move_direction.normalized()

	# Constrain velocity strictly to the wall plane, no motion into or away from the wall
	player.velocity = move_direction * player.speed_current

	# Ensure the visuals face the wall (optional subtle alignment)
	var wall_forward = -collision_normal_normalized
	# Project the forward onto the plane perpendicular to up to avoid pitching toward ground/ceiling
	wall_forward = (wall_forward - player.up_direction * wall_forward.dot(player.up_direction)).normalized()
	if wall_forward.length() > 0.0 and player.position != player.position + wall_forward:
		player.visuals.look_at(player.position + wall_forward, player.up_direction)


## Snaps the player to the wall they are climbing/hanging on.
func move_to_wall() -> void:
	# Get the collision point
	var collision_point = player.ray_cast_high.get_collision_point()

	# [DEBUG] Draw a debug sphere at the collision point
	#player.debug.draw_debug_sphere(collision_point, Color.RED)

	# Calculate the direction from the player to collision point
	var direction = (collision_point - player.position).normalized()

	# Calculate new point by moving back from point along the direction by the given player radius
	collision_point = collision_point - direction * player.collision_width

	# [DEBUG] Draw a debug sphere at the adjusted collision point
	#player.debug.draw_debug_sphere(collision_point, Color.YELLOW)

	# Adjust the point relative to the player's height
	collision_point = Vector3(collision_point.x, player.position.y, collision_point.z)

	# Move the player to the collision point
	player.global_position = collision_point

	# [DEBUG] Draw a debug sphere at the collision point
	#player.debug.draw_debug_sphere(collision_point, Color.GREEN)

	# Get the collision normal
	var collision_normal = player.ray_cast_high.get_collision_normal()

	# Calculate the wall direction
	var wall_direction = -collision_normal

	# Make the player face the wall while keeping upright (flatten onto plane perpendicular to up)
	wall_direction = (wall_direction - player.up_direction * wall_direction.dot(player.up_direction)).normalized()
	if wall_direction.length() > 0.0 and player.position != player.position + wall_direction:
		player.visuals.look_at(player.position + wall_direction, player.up_direction)


## Called when a state needs to transition to another.
func transition(from_state: String, to_state: String):
	# Get the "from" scene
	var from_scene = get_parent().find_child(from_state)
	# Get the "to" scene
	var to_scene = get_parent().find_child(to_state)
	# Check if the scenes exist
	if from_scene and to_scene:
		# Stop processing the "from" scene
		from_scene.stop()
		# Start processing the "to" scene
		to_scene.start()


func transition_state(from_state: States.State, to_state: States.State):
	# Get the "from" scene
	var from_name = get_state_name(from_state)
	var from_scene = get_parent().find_child(from_name)
	# Get the "to" scene
	var to_name = get_state_name(to_state)
	var to_scene = get_parent().find_child(to_name)
	# Check if the scenes exist
	if from_scene and to_scene:
		# Stop processing the "from" scene
		from_scene.stop()
		# Start processing the "to" scene
		to_scene.start()
