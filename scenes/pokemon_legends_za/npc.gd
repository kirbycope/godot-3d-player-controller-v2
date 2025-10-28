extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_animation = "Climbing_Incline_Steep/mixamo_com"
	if $AnimationPlayer.current_animation != target_animation:
		$AnimationPlayer.play(target_animation)
