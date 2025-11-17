extends Node3D

@onready var animation_player: AnimationPlayer = $Visuals/AnimationPlayer


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	play_animation()


func play_animation() -> void:
	#animation_player.play_section("Armature|White Duck_TempMotion|White Duck_TempMotion", 0.0, 9.6) # Idle
	#animation_player.play_section("Armature|White Duck_TempMotion|White Duck_TempMotion", 9.7, 10.8) # Walk
	#animation_player.play_section("Armature|White Duck_TempMotion|White Duck_TempMotion", 10.9) # Eat
	if not animation_player.is_playing():
		animation_player.play_section("Armature|White Duck_TempMotion|White Duck_TempMotion", 0.0, 9.6)
