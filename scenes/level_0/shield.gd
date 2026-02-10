extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_detection_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.


func _on_player_detection_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.
