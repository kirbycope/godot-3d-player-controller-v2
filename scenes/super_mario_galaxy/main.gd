extends Node3D

#const MOUSE_CURSOR_ARROW = preload("uid://dqs8cxh3k2t0a")
const MOUSE_CURSOR_ARROW = preload("uid://dmw8j7h0b8bri")


# Called when the node enters the scene tree for the first time.
func _ready():
	# Normalize texture size to 64x64
	var resized_texture = ImageTexture.new()
	var image = MOUSE_CURSOR_ARROW.get_image()
	image.resize(64, 64, Image.INTERPOLATE_LANCZOS)
	resized_texture.set_image(image)
	var hotspot := Vector2(32.0, 32.0)
	Input.set_custom_mouse_cursor(resized_texture, Input.CURSOR_ARROW, hotspot)
