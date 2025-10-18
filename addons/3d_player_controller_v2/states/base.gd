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

	# Ⓑ/[shift] _pressed_ -> Stop "climbing"/"hanging"
	if player.is_climbing or player.is_hanging:
		if event.is_action_pressed(player.controls.button_1):
			# Start "falling"
			transition_state(player.current_state, States.State.FALLING)
			return

	# Ⓑ/[shift] _pressed_ -> Start "sprinting"
	if player.enable_sprinting:
		if event.is_action_pressed(player.controls.button_1) \
		and not player.is_sprinting \
		and player.is_on_floor():
			transition_state(player.current_state, States.State.SPRINTING)
			return


## Called once on each physics tick, and allows Nodes to synchronize their logic with physics ticks.
func _physics_process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check if the player is looking at a grabable ledge -> Start "hanging"
	if player.enable_hanging:
		if not player.is_hanging \
		and not player.ray_cast_top.is_colliding() \
		and player.ray_cast_high.is_colliding():
			# Start "hanging"
			transition_state(player.current_state, States.State.HANGING)
			return

	# Check if the player is not on a floor -> Start "falling"
	if not player.is_on_floor() \
	and not player.is_climbing \
	and not player.is_flying \
	and not player.is_jumping \
	and not player.is_punching_left \
	and not player.is_punching_right:
		transition_state(player.current_state, States.State.FALLING)
		return

	# Change state based on velocity
	if not player.is_climbing \
	and not player.is_crawling \
	and not player.is_crouching \
	and not player.is_punching_left \
	and not player.is_punching_right \
	and not player.is_swimming:

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
