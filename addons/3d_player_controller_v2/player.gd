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
var is_jumping: bool = false ## Is the player jumping?
var is_running: bool = false ## Is the player running?
var is_standing: bool = true ## Is the player standing?
var is_walking: bool = false ## Is the player walking?
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") ## Default gravity value
var speed_current: float = 0.0 ## Current speed

@onready var animation_player: AnimationPlayer = $Visuals/Godette/AnimationPlayer
@onready var camera_mount = $CameraMount
@onready var camera = camera_mount.get_node("Camera3D")
@onready var controls = $Controls


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
		# Start "jumping"
		#transition(NODE_NAME, "Jumping")
		velocity.y = jump_velocity


## Called on each idle frame, prior to rendering, and after physics ticks have been processed.
func _process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return


## Called once on each physics tick, and allows Nodes to synchronize their logic with physics ticks.
func _physics_process(delta):
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Create a variable to store the input vector
	var input_dir = Vector2.ZERO
	# Get the input vector by specifying four actions for the positive and negative X and Y axes
	input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Convert the 2D vector into a 3D vector and then normalize the result
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# Update velocities
	velocity.x = direction.x * speed_current
	velocity.y -= gravity * delta
	velocity.z = direction.z * speed_current
	# Move the body based on velocity
	move_and_slide()
