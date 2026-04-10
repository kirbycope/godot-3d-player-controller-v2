extends Node
class_name BaseState
## The base state that all other states inherit from.

@export var walk_run_threshold := 0.5 ## Input magnitude threshold separating walk vs run

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called once on each physics tick, and allows Nodes to synchronize their logic with physics ticks.
func _physics_process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Check if the player is looking at a grabble ledge -> Start "hanging"
	if player.enable_hanging:
		var can_hang = not player.is_flying \
			and not player.is_hanging \
			and not player.is_mantling \
			and not player.is_on_floor() \
			and not player.is_ragdolling \
			and not player.is_skateboarding \
			and not player.ray_cast_top.is_colliding() \
			and player.ray_cast_high.is_colliding()
		if can_hang:
			var high_collider = player.ray_cast_high.get_collider()
			if not (high_collider is PhysicsBody3D or high_collider is SoftBody3D):
				transition_state(player.current_state, States.State.HANGING)
				return

	# Return early if the player is in a state that handles its own state transitions
	var is_busy = player.is_climbing \
		or player.is_climbing_ladder \
		or player.is_crawling \
		or player.is_crouching \
		or player.is_driving \
		or player.is_dying \
		or player.is_falling \
		or player.is_flipping \
		or player.is_flying \
		or player.is_hanging \
		or player.is_jumping \
		or player.is_mantling \
		or player.is_paragliding \
		or player.is_pushing \
		or player.is_ragdolling \
		or player.is_reacting \
		or player.is_rolling \
		or player.is_sitting \
		or player.is_sliding \
		or player.is_skateboarding \
		or player.is_swimming
	if is_busy:
		return

	# Check for player input
	var has_input = player.input_direction != Vector2.ZERO
	var input_len = player.input_direction.length()

	# Check if there is something in front of the player's mid-section
	var middle_collider = player.ray_cast_middle.get_collider()
	var middle_hit = player.ray_cast_middle.is_colliding() and not middle_collider is CharacterBody3D

	# Check if there is something in front of the player's chest
	var high_collider = player.ray_cast_high.get_collider()
	var high_hit = player.ray_cast_high.is_colliding() and not high_collider is CharacterBody3D

	# Reset double-jump flag when on the ground
	if player.is_on_floor():
		player.is_double_jumping = false

	# Check if the player is not moving and has no input -> Start "standing"
	if not has_input and not player.is_standing and not player.is_crouching:
		transition_state(player.current_state, States.State.STANDING)
		return

	# Check if there is something in front of the player and the player is moving -> Start "pushing"
	if has_input and (middle_hit or high_hit) and player.enable_pushing and not player.is_pushing:
		transition_state(player.current_state, States.State.PUSHING)
		return

	# Ⓑ/[shift] _pressed_ -> Start "sprinting"
	if has_input and Input.is_action_pressed(Controls.BUTTON_1) \
	and player.enable_sprinting \
	and not player.is_dead \
	and not player.is_riding \
	and not player.is_sprinting:
		transition_state(player.current_state, States.State.SPRINTING)
		return

	# Check if the player's current speed is slower than or equal to "walking" speed -> Start "walking"
	if has_input and input_len <= walk_run_threshold and not player.is_walking and not player.is_sprinting:
		transition_state(player.current_state, States.State.WALKING)
		return

	# Check if the player speed is faster than "walking" but slower than or equal to "running" -> Start "running"
	if input_len > walk_run_threshold and not player.is_running and not player.is_sprinting:
		transition_state(player.current_state, States.State.RUNNING)
		return


## Returns the string name of a state.
func get_state_name(state: States.State) -> String:
	return States.State.keys()[state].capitalize().replace(" ", "")


## Called when a state needs to transition to another.
func transition_state(from_state: States.State, to_state: States.State) -> void:
	var states_parent = get_parent()
	var from_scene = states_parent.find_child(get_state_name(from_state))
	var to_scene = states_parent.find_child(get_state_name(to_state))
	if from_scene and to_scene:
		from_scene.stop()
		to_scene.start()
		player.previous_state = from_state
