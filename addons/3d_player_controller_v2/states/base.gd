class_name BaseState
extends Node

@export var walk_run_threshold := 0.5 ## Input magnitude threshold separating walk vs run

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called once on each physics tick, and allows Nodes to synchronize their logic with physics ticks.
func _physics_process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the player's animation is locked
	if player.is_animation_locked: return

	# Check if the player is looking at a grabable ledge -> Start "hanging"
	if player.enable_hanging:
		if not player.is_flying \
		and not player.is_hanging \
		and not player.is_mantling \
		and not player.is_on_floor() \
		and not player.is_ragdolling \
		and not player.is_skateboarding \
		and not player.ray_cast_top.is_colliding() \
		and player.ray_cast_high.is_colliding():
			if not player.ray_cast_high.get_collider() is CharacterBody3D \
			and not player.ray_cast_high.get_collider() is RigidBody3D \
			and not player.ray_cast_high.get_collider() is SoftBody3D:
				transition_state(player.current_state, States.State.HANGING)
				return

	# Change state based on velocity
	var is_busy = player.is_climbing \
		or player.is_climbing_ladder \
		or player.is_crawling \
		or player.is_crouching \
		or player.is_driving \
		or player.is_falling \
		or player.is_flying \
		or player.is_hanging \
		or player.is_jumping \
		or player.is_mantling \
		or player.is_paragliding \
		or player.is_pushing \
		or player.is_ragdolling \
		or player.is_rolling \
		or player.is_sitting \
		or player.is_sliding \
		or player.is_skateboarding \
		or player.is_swimming
	if not is_busy:
		var has_input = player.input_direction != Vector2.ZERO
		var input_len = player.input_direction.length()

		# Reset double-jump flag when on the ground
		if player.is_on_floor():
			player.is_double_jumping = false

		# Check if the player is not moving and has no input -> Start "standing"
		if not has_input \
		and not player.is_standing \
		and not player.is_crouching:
			transition_state(player.current_state, States.State.STANDING)
			return
		
		# Check if there is something in front of the player and the player is moving -> Start "pushing"
		elif has_input \
		and (player.ray_cast_middle.is_colliding() or player.ray_cast_high.is_colliding()) \
		and player.enable_pushing \
		and not player.is_pushing:
			transition_state(player.current_state, States.State.PUSHING)
			return

		# Check if the sprint button is pressed -> Start "sprinting"
		elif has_input \
		and Input.is_action_pressed(Controls.BUTTON_1) \
		and player.enable_sprinting \
		and not player.is_sprinting:
			transition_state(player.current_state, States.State.SPRINTING)
			return

		# Check if the player's current speed is slower than or equal to "walking" speed -> Start "walking"
		elif has_input \
		and input_len <= walk_run_threshold \
		and not player.is_walking \
		and not player.is_sprinting:
			transition_state(player.current_state, States.State.WALKING)
			return

		# Check if the player speed is faster than "walking" but slower than or equal to "running" -> Start "running"
		elif input_len > walk_run_threshold \
		and not player.is_running \
		and not player.is_sprinting:
			transition_state(player.current_state, States.State.RUNNING)
			return


## Returns the string name of a state.
func get_state_name(state: States.State) -> String:
	# Return the state name with the first letter capitalized
	return States.State.keys()[state].capitalize().replace(" ", "")


## Called when a state needs to transition to another.
func transition_state(from_state: States.State, to_state: States.State) -> void:
	# Get the "from" scene
	var from_name = get_state_name(from_state)
	var from_scene = get_parent().find_child(from_name)
	# Get the "to" scene
	var to_name = get_state_name(to_state)
	var to_scene = get_parent().find_child(to_name)
	# Check if the scenes exist
	if from_scene and to_scene:
		#print(from_name, " -> ", to_name) # DEBUGGING
		# Stop processing the "from" scene
		from_scene.stop()
		# Start processing the "to" scene
		to_scene.start()
		# Update the player's previous state
		player.previous_state = from_state
