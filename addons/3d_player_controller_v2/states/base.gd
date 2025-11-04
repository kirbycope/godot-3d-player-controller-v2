class_name BaseState
extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called once on each physics tick, and allows Nodes to synchronize their logic with physics ticks.
func _physics_process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Do nothing if the player's animation is locked
	if player.is_animation_locked: return

	# Check if the player is looking at a grabable ledge -> Start "hanging"
	if player.enable_hanging:
		if not player.is_flying \
		and not player.is_hanging \
		and not player.ray_cast_top.is_colliding() \
		and player.ray_cast_high.is_colliding() \
		and not player.is_skateboarding:
			if not player.ray_cast_high.get_collider() is CharacterBody3D \
			and not player.ray_cast_high.get_collider() is RigidBody3D \
			and not player.ray_cast_high.get_collider() is SoftBody3D:
				transition_state(player.current_state, States.State.HANGING)
				return

	# Check if the player is not on a floor -> Start "falling"
	if not player.is_on_floor() \
	and not player.is_climbing \
	and not player.is_climbing_ladder \
	and not player.is_falling \
	and not player.is_flying \
	and not player.is_hanging \
	and not player.is_jumping \
	and not player.is_paragliding \
	#and not player.is_punching_left \
	and not player.is_punching_right \
	and not player.is_skateboarding \
	and not player.is_swimming:
		transition_state(player.current_state, States.State.FALLING)
		return

	# Change state based on velocity
	if not player.is_climbing \
	and not player.is_climbing_ladder \
	and not player.is_crawling \
	and not player.is_crouching \
	and not player.is_driving \
	and not player.is_falling \
	and not player.is_flying \
	and not player.is_hanging \
	and not player.is_jumping \
	and not player.is_paragliding \
	#and not player.is_punching_left \
	and not player.is_punching_right \
	and not player.is_rolling \
	and not player.is_sliding \
	and not player.is_skateboarding \
	and not player.is_swimming:

		# Reset double-jump flag when on the ground
		if player.is_on_floor():
			player.is_double_jumping = false

		# Check if the player is not moving and has no input -> Start "standing"
		if player.input_direction == Vector2.ZERO \
		and not player.is_standing \
		and not player.is_crouching:
			transition_state(player.current_state, States.State.STANDING)
			return

		# Check if the sprint button is pressed -> Start "sprinting"
		elif player.input_direction != Vector2.ZERO \
		and Input.is_action_pressed(player.controls.button_1) \
		and player.enable_sprinting \
		and not player.is_sprinting:
			transition_state(player.current_state, States.State.SPRINTING)
			return

		# Check if the player's current speed is slower than or equal to "walking" speed -> Start "walking"
		elif Vector2.ZERO < player.input_direction \
		and abs(player.input_direction.length()) <= 0.5 \
		and not player.is_walking \
		and not player.is_sprinting:
			transition_state(player.current_state, States.State.WALKING)
			return

		# Check if the player speed is faster than "walking" but slower than or equal to "running" -> Start "running"
		elif abs(player.input_direction.length()) > 0.5 \
		and not player.is_running \
		and not player.is_sprinting:
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
		print(from_name, " -> ", to_name) # DEBUGGING
		# Stop processing the "from" scene
		from_scene.stop()
		# Start processing the "to" scene
		to_scene.start()
		# Update the player's previous state
		player.previous_state = from_state
