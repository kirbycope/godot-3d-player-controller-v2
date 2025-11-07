extends BaseState

const NODE_NAME := "Ragdolling"
const NODE_STATE := States.State.RAGDOLLING

var time_ragdolling: float = 0.0 ## The time spent in the "ragdolling" state."


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# (A)/[Space] _pressed_ (after 3 seconds or ragdolling) -> Start "standing"
	if event.is_action_pressed(player.controls.button_0) and time_ragdolling > 3.0:
		transition_state(player.current_state, States.State.JUMPING)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Have the player follow the hips bone position, so that the camera follows the ragdoll
	if not player.pause.visible:
		time_ragdolling += delta
		if player.skeleton.has_node("PhysicalBoneSimulator3D/Physical Bone Hips"):
			player.global_position = player.skeleton.get_node("PhysicalBoneSimulator3D/Physical Bone Hips").global_position


## Start ragdoll state
func start() -> void:
	# Enable this state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.RAGDOLLING

	# Flag the player as "ragdolling"
	player.is_ragdolling = true

	# Reset timer
	time_ragdolling = 0.0

	# Check if player has a physical bone simulator
	if player.physical_bone_simulator:

		# Ensure collision is disabled
		player.collision_shape.disabled = true

		# Now activate the ragdoll simulation
		player.physical_bone_simulator.active = true
		player.physical_bone_simulator.physical_bones_start_simulation()


## Stop ragdoll state
func stop() -> void:
	# Disable this state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "ragdolling"
	player.is_ragdolling = false

	# Ensure ragdoll is properly stopped
	if player.physical_bone_simulator:
		if player.physical_bone_simulator.active:
			player.physical_bone_simulator.physical_bones_stop_simulation()
			player.physical_bone_simulator.active = false

	# Ensure collision is re-enabled
	player.collision_shape.disabled = false

	# [Re]Set time spent in ragdoll state
	time_ragdolling = 0.0
