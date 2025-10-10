extends CharacterBody3D

enum Perspective {
	THIRD_PERSON,
	FIRST_PERSON
}

@export var jump_velocity: float = 4.5 ## Jump velocity
@export var perspective: Perspective = Perspective.THIRD_PERSON ## Camera perspective
@export var speed_climbing: float = 0.5 ## Speed while climbing
@export var speed_crawling: float = 0.75 ## Speed while crawling
@export var speed_flying: float = 5.0 ## Speed while flying
@export var speed_flying_fast: float = 10.0 ## Speed while flying fast
@export var speed_hanging: float = 0.25 ## Speed while hanging (shimmying)
@export var speed_rolling: float = 2.0 ## Speed while rolling
@export var speed_running: float = 3.5 ## Speed while running
@export var speed_sprinting: float = 5.0 ## Speed while sprinting
@export var speed_swimming: float = 3.0 ## Speed while swimming
@export var speed_walking: float = 1.0 ## Speed while walking

var current_state: States.State ## The current state of the player.
var input_direction: Vector2 = Vector2.ZERO ## The direction of the player input (UP/DOWN, LEFT/RIGHT).
var is_crawling: bool = false ## Is the player crawling?
var is_crouching: bool = false ## Is the player crouching?
var is_falling: bool = false ## Is the player falling?
var is_jumping: bool = false ## Is the player jumping?
var is_running: bool = false ## Is the player running?
var is_standing: bool = false ## Is the player standing?
var is_sprinting: bool = false ## Is the player sprinting?
var is_walking: bool = false ## Is the player walking?
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") ## Default gravity value
var gravitating_towards ## The Node the player is being pulled towards (if any)
var speed_current: float = 0.0 ## Current speed

@onready var animation_player: AnimationPlayer = $Visuals/Godette/AnimationPlayer
@onready var base_state: BaseState = $States/Base
@onready var camera_mount = $CameraMount
@onready var camera = camera_mount.get_node("Camera3D")
@onready var controls = $Controls
@onready var visuals = $Visuals


## Called when the node is "ready", i.e. when both the node and its children have entered the scene tree.
func _ready():
	# Start "standing"
	$States/Standing.start()


## Called when there is an input event.
func _input(event):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Ⓐ/[Space] _pressed_ and jumping is enabled -> Start "jumping"
	if event.is_action_pressed(controls.button_0) and is_on_floor():
		base_state.transition_state(current_state, States.State.JUMPING)

	# Check for mouse motion
	if event is InputEventMouseMotion:
		# Check if the mouse is captured
		if Input.get_mouse_mode() in [Input.MOUSE_MODE_CAPTURED, Input.MOUSE_MODE_HIDDEN]:
			# Rotate camera based on mouse movement
			camera.camera_rotate_by_mouse(event)


## Called on each idle frame, prior to rendering, and after physics ticks have been processed.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Rotate the player to align with the new up direction
	var target_basis = Basis()
	target_basis.y = up_direction
	target_basis.x = -transform.basis.z.cross(up_direction).normalized()
	target_basis.z = target_basis.x.cross(up_direction).normalized()
	target_basis = target_basis.orthonormalized()
	transform.basis = target_basis


## Called once on each physics tick, and allows Nodes to synchronize their logic with physics ticks.
func _physics_process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return

	# Get the input vector by specifying four actions for the positive and negative X and Y axes
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Set the player's movement speed based on the input magnitude
	if speed_current == 0.0 and input_direction != Vector2.ZERO:
		speed_current = input_direction.length() * speed_running

	# Convert the 2D vector into a 3D vector and then normalize the result
	var direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	if direction:
		# Update linear velocities based on direction and speed
		velocity.x = direction.x * speed_current
		velocity.z = direction.z * speed_current
		# Update the visuals to look in the direction based on player input
		visuals.look_at(position + direction, up_direction)

	# Apply gravity
	if gravitating_towards:
		# Calculate the direction towards the gravity source center
		var gravity_direction = (gravitating_towards.global_position - global_position).normalized()
		# Apply gravity towards the target object's center
		velocity += gravity_direction * gravity * delta
		# Set the new "up" direction based on gravity
		up_direction = -gravity_direction
	else:
		# Update the vertical velocity with global gravity
		velocity.y -= gravity * delta
		up_direction = Vector3.UP

	# Move the body based on velocity
	move_and_slide()
