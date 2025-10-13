extends Node3D

const COLLECTABLE = preload("uid://dkot3p2xn8i5q")
#const MOUSE_CURSOR_ARROW = preload("uid://dqs8cxh3k2t0a")
const MOUSE_CURSOR_ARROW = preload("uid://dmw8j7h0b8bri")

@onready var collectable = $Collectable
"res://scenes/super_mario_galaxy/collectable.tscn"


## Called when the node enters the scene tree for the first time.
func _ready():
	change_cursor()
	spawn_collectables()


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
