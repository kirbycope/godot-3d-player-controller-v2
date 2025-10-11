extends Node3D

@onready var player = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Capture the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
