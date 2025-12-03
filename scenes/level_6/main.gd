extends Node3D
## Super Mario Galaxy scene script configuration.

const COLLECTABLE: PackedScene = preload("uid://dkot3p2xn8i5q")
#const MOUSE_CURSOR_ARROW: Texture2D = preload("uid://dqs8cxh3k2t0a")
const MOUSE_CURSOR_ARROW: Texture2D = preload("uid://dmw8j7h0b8bri")

@onready var collectable: Node3D = $Collectable
@onready var player: CharacterBody3D = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.camera.set_camera_perspective(player.camera.Perspective.THIRD_PERSON)
	player.enable_crawling = true
	player.enable_crouching = true
	player.enable_hanging = true
	player.enable_jumping = true
	player.enable_sprinting = true
	player.enable_swimming = true

	change_cursor()
	spawn_collectables()


## Called when the node is about to leave the SceneTree.
func _exit_tree() -> void:
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)


## Set the cursor to a custom texture.
func change_cursor() -> void:
	var resized_texture = ImageTexture.new()
	var image = MOUSE_CURSOR_ARROW.get_image()
	image.resize(64, 64, Image.INTERPOLATE_LANCZOS)
	resized_texture.set_image(image)
	var hotspot := Vector2(32.0, 32.0)
	Input.set_custom_mouse_cursor(resized_texture, Input.CURSOR_ARROW, hotspot)


## Spawn more collectables at the initial collectable location.
func spawn_collectables() -> void:
	var location := collectable.global_position
	for i in range(5):
		var new_collectable := COLLECTABLE.instantiate()
		add_child(new_collectable)
		new_collectable.global_position = location + Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
