extends Node3D

const COLLECTABLE = preload("uid://dkot3p2xn8i5q")
#const MOUSE_CURSOR_ARROW = preload("uid://dqs8cxh3k2t0a")
const MOUSE_CURSOR_ARROW = preload("uid://dmw8j7h0b8bri")

@onready var collectable = $Collectable
@onready var player = $Player


## Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.camera.lock_camera = false
	player.enable_climbing = false
	player.enable_crawling = true
	player.enable_crouching = true
	player.enable_double_jumping = false
	player.enable_flying = false
	player.enable_holding_objects = false
	player.enable_jumping = true
	player.enable_kicking = false
	player.enable_navigation = false
	player.enable_punching = false
	player.enable_retical = false
	player.enable_rolling = false
	player.enable_sprinting = true
	player.enable_swimming = true
	player.lock_movement_x = false
	player.lock_movement_y = false
	player.lock_movement_z = false
	player.camera.enable_head_bobbing = false
	#player.camera.toggle_perspective() # Run in _ready() to start in 1st person

	change_cursor()
	spawn_collectables()


## Called when the node is about to leave the SceneTree.
func _exit_tree():
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)


## Set the cursor to a custom texture.
func change_cursor():
	var resized_texture = ImageTexture.new()
	var image = MOUSE_CURSOR_ARROW.get_image()
	image.resize(64, 64, Image.INTERPOLATE_LANCZOS)
	resized_texture.set_image(image)
	var hotspot := Vector2(32.0, 32.0)
	Input.set_custom_mouse_cursor(resized_texture, Input.CURSOR_ARROW, hotspot)


## Spawn more collectables at the initial collectable location.
func spawn_collectables():
	var location = collectable.global_position
	for i in range(5):
		var new_collectable = COLLECTABLE.instantiate()
		add_child(new_collectable)
		new_collectable.global_position = location + Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
