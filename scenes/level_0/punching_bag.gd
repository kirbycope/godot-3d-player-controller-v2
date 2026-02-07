extends RigidBody3D
## Punching bag that plays random impact sounds via RPC triggers.

const SFX_1: AudioStream = preload("res://assets/audio/punching_bag/594416__cashcarlo__punching-bag-being-punched-outside_k1.wav")
const SFX_2: AudioStream = preload("res://assets/audio/punching_bag/594416__cashcarlo__punching-bag-being-punched-outside_k2.wav")
const SFX_3: AudioStream = preload("res://assets/audio/punching_bag/594416__cashcarlo__punching-bag-being-punched-outside_k3.wav")
const SFX_4: AudioStream = preload("res://assets/audio/punching_bag/594416__cashcarlo__punching-bag-being-punched-outside_p1.wav")
const SFX_5: AudioStream = preload("res://assets/audio/punching_bag/594416__cashcarlo__punching-bag-being-punched-outside_p2.wav")
const SFX_6: AudioStream = preload("res://assets/audio/punching_bag/594416__cashcarlo__punching-bag-being-punched-outside_p3.wav")

@onready var audio_stream_player: AudioStreamPlayer3D = get_parent().get_node("AudioStreamPlayer3D")


@rpc("any_peer", "call_local")
func animate_hit_low_left(player: CharacterBody3D = null) -> void:
	play_kick_sound()
	if player:
		pass # Placeholder


@rpc("any_peer", "call_local")
func animate_hit_low_right(player: CharacterBody3D = null) -> void:
	play_kick_sound()
	if player:
		pass # Placeholder


@rpc("any_peer", "call_local")
func animate_hit_high_left(player: CharacterBody3D = null) -> void:
	play_punch_sound()
	if player:
		pass # Placeholder


@rpc("any_peer", "call_local")
func animate_hit_high_right(player: CharacterBody3D = null) -> void:
	play_punch_sound()
	if player:
		pass # Placeholder


func play_kick_sound() -> void:
	var sound_choice := randi() % 3
	match sound_choice:
		0:
			audio_stream_player.stream = SFX_1
		1:
			audio_stream_player.stream = SFX_2
		2:
			audio_stream_player.stream = SFX_3
	# Play the sound effct
	audio_stream_player.play()


func play_punch_sound() -> void:
	var sound_choice := randi() % 3
	match sound_choice:
		0:
			audio_stream_player.stream = SFX_4
		1:
			audio_stream_player.stream = SFX_5
		2:
			audio_stream_player.stream = SFX_6
	# Play the sound effct
	audio_stream_player.play()
