extends BaseState

const ANIMATION_RUNNING := "AnimationLibrary_Godot/Sprint"
const NODE_NAME := "Navigating"
const NODE_STATE := States.State.NAVIGATING

@onready var navigation_agent = player.get_node("NavigationAgent3D")


## Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the "navigation_finished" signal
	navigation_agent.navigation_finished.connect(_on_navigation_finished)


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Check for player input
	if event.is_action_pressed("move_up") \
	or event.is_action_pressed("move_down") \
	or event.is_action_pressed("move_left") \
	or event.is_action_pressed("move_right"):
		# Set target position to the player's current position (ending navigation)
		navigation_agent.target_position = player.global_position


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Play the animation
	play_animation()


## Called once on each physics tick, and allows Nodes to synchronize their logic with physics ticks.
func _physics_process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Navigate to the next position
	if not navigation_agent.is_navigation_finished():
		navigate_to_next_position()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != ANIMATION_RUNNING:
		# Play the "running" animation
		player.animation_player.play(ANIMATION_RUNNING)


## Navigate to the next position in the path. Called during physics process if navigating.
func navigate_to_next_position() -> void:
	var next_point = navigation_agent.get_next_path_position()
	var new_velocity = (next_point - player.global_position).normalized() * player.speed_running
	player.velocity.x = new_velocity.x
	player.velocity.z = new_velocity.z
	#virtual_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	# Face the direction of movement
	player.visuals.look_at(player.position + Vector3(player.velocity.x, 0, player.velocity.z), player.up_direction)



## Called when the NavigationAgent3D has finished.
func _on_navigation_finished():
	player.is_navigating = false
	# Stop the player's movement
	player.velocity = Vector3.ZERO
	# Start "standing"
	transition_state(NODE_STATE, States.State.STANDING)


## Start "navigating".
func start():
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.NAVIGATING

	# Flag the player as "navigating"
	player.is_navigating = true

	# Navigate to the next position
	navigate_to_next_position()


## Stop "navigating".
func stop():
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "navigating"
	player.is_navigating = false
