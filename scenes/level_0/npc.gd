extends CharacterBody3D

@export_enum("Mixamo", "Quaternius") var animation_set := 0 ## Animation set selection; 0=Mixamo, 1=Quaternius

const DAMAGE_1_ALEX = preload("res://assets/audio/super_dialogue_audio_pack_v1/7 - Damage/Male/Alex Brodie/damage_1_alex.wav")
const DAMAGE_2_ALEX = preload("res://assets/audio/super_dialogue_audio_pack_v1/7 - Damage/Male/Alex Brodie/damage_2_alex.wav")
const DAMAGE_3_ALEX = preload("res://assets/audio/super_dialogue_audio_pack_v1/7 - Damage/Male/Alex Brodie/damage_3_alex.wav")

var is_reacting_low_left: bool = false
var is_reacting_low_right: bool = false
var is_reacting_high_left: bool = false
var is_reacting_high_right: bool = false
var setup_character: GDScript = preload("res://addons/3d_player_controller_v2/setup_character.gd")

@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready() -> void:
	# Setup animations for each rigged character model in this NPC
	for child in get_children():
		# Skip physics and audio nodes
		if child is PhysicsBody3D or child is CollisionShape3D or child is AudioStreamPlayer3D or child is Area3D:
			continue

		# Setup animations for this character component
		setup_character.add_animations(child, null)

		# Setup physical bone simulators for this character component
		setup_character.physical_bone_simulators(child)


func _process(_delta: float) -> void:
	play_animation()


func play_animation() -> void:
	var mix_anim := ""
	var quat_anim := ""
	if is_reacting_low_left:
		mix_anim = Reacting.MIX_ANIMATION_REACTING_LOW_LEFT
		quat_anim = Reacting.QUAT_ANIMATION_REACTING_LOW_LEFT
	elif is_reacting_low_right:
		mix_anim = Reacting.MIX_ANIMATION_REACTING_LOW_RIGHT
		quat_anim = Reacting.QUAT_ANIMATION_REACTING_LOW_RIGHT
	elif is_reacting_high_left:
		mix_anim = Reacting.MIX_ANIMATION_REACTING_HIGH_LEFT
		quat_anim = Reacting.QUAT_ANIMATION_REACTING_HIGH_LEFT
	elif is_reacting_high_right:
		mix_anim = Reacting.MIX_ANIMATION_REACTING_HIGH_RIGHT
		quat_anim = Reacting.QUAT_ANIMATION_REACTING_HIGH_RIGHT
	else:
		mix_anim = Standing.MIX_ANIMATION_STANDING_IDLE
		quat_anim = Standing.QUAT_ANIMATION_STANDING_IDLE

	var anim = quat_anim if animation_set == 1 else mix_anim
	if animation_player_current_animation() != anim:
		animation_player_play(anim)
		animation_player_connect("animation_finished", _on_animation_finished)


func _on_animation_finished(animation_name: String) -> void:
	if animation_name == Reacting.MIX_ANIMATION_REACTING_LOW_LEFT \
	or animation_name == Reacting.QUAT_ANIMATION_REACTING_LOW_LEFT:
		is_reacting_low_left = false
	elif animation_name == Reacting.MIX_ANIMATION_REACTING_LOW_RIGHT \
	or animation_name == Reacting.QUAT_ANIMATION_REACTING_LOW_RIGHT:
		is_reacting_low_right = false
	elif animation_name == Reacting.MIX_ANIMATION_REACTING_HIGH_LEFT \
	or animation_name == Reacting.QUAT_ANIMATION_REACTING_HIGH_LEFT:
		is_reacting_high_left = false
	elif animation_name == Reacting.MIX_ANIMATION_REACTING_HIGH_RIGHT \
	or animation_name == Reacting.QUAT_ANIMATION_REACTING_HIGH_RIGHT:
		is_reacting_high_right = false


## Connects a [Signal] (by name) to a [Callable] on all [AnimationPlayer] nodes found under [character] (recursively).
func animation_player_connect(_signal: String, callable: Callable) -> void:
	for animation_player in animation_players():
		if not animation_player.is_connected(_signal, callable):
			animation_player.connect(_signal, callable)


## Gets the _current animation_ name from the first [AnimationPlayer] node found as a child of [character].
func animation_player_current_animation() -> String:
	var animation_name: String = "" ## The key of the currently playing animation.
	for animation_player in animation_players():
		animation_name = animation_player.current_animation
		break
	return animation_name


## Plays an animation on all [AnimationPlayer] nodes found under [character] (recursively).
func animation_player_play(_name: StringName = &"", custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false) -> void:
	# Skip if no animation name was provided
	if _name == &"": return

	# Play the animation on each AnimationPlayer that has it
	for animation_player in animation_players():
		if animation_player.has_animation(_name):
			animation_player.call_deferred("play", _name, custom_blend, custom_speed, from_end)
		else: push_warning("Animation '%s' not found on AnimationPlayer '%s'" % [_name, animation_player.name]) ## DEBUGGING


## Gets all child [AnimationPlayer] nodes found under [character] (recursively).
func animation_players() -> Array:
	var _animation_players: Array = []
	# Search for all [AnimationPlayer] nodes
	var search_results = find_children("*", "AnimationPlayer", true, false)
	# Add each found node to the array
	for node in search_results:
		_animation_players.append(node)
	#print("Found ", _animation_players.size(), " AnimationPlayer(s) under `", get_path(), "`") # DEBUGGING
	return _animation_players


func _reset_reactions() -> void:
	is_reacting_low_left = false
	is_reacting_low_right = false
	is_reacting_high_left = false
	is_reacting_high_right = false


@rpc("any_peer", "call_local")
func animate_hit_low_left(player: CharacterBody3D = null) -> void:
	_reset_reactions()
	is_reacting_low_left = true
	play_damage_sound_effect()
	if player:
		pass # Placeholder


@rpc("any_peer", "call_local")
func animate_hit_low_right(player: CharacterBody3D = null) -> void:
	_reset_reactions()
	is_reacting_low_right = true
	play_damage_sound_effect()
	if player:
		pass # Placeholder


@rpc("any_peer", "call_local")
func animate_hit_high_left(player: CharacterBody3D = null) -> void:
	_reset_reactions()
	is_reacting_high_left = true
	play_damage_sound_effect()
	if player:
		pass # Placeholder


@rpc("any_peer", "call_local")
func animate_hit_high_right(player: CharacterBody3D = null) -> void:
	_reset_reactions()
	is_reacting_high_right = true
	play_damage_sound_effect()
	if player:
		pass # Placeholder


## Plays the sound effect for when the character takes damage.
func play_damage_sound_effect() -> void:
	var sounds = [
		DAMAGE_1_ALEX,
		DAMAGE_2_ALEX,
		DAMAGE_3_ALEX,
	]
	if audio_stream_player.stream in sounds \
	and audio_stream_player.playing:
		return # Prevent overlapping sounds
	audio_stream_player.stream = sounds[randi() % sounds.size()]
	audio_stream_player.play()


func _is_reacting_animation_playing() -> bool:
	var current_anim = animation_player_current_animation()
	var reacting_animations = [
		Reacting.MIX_ANIMATION_REACTING_LOW_LEFT,
		Reacting.MIX_ANIMATION_REACTING_LOW_RIGHT,
		Reacting.MIX_ANIMATION_REACTING_HIGH_LEFT,
		Reacting.MIX_ANIMATION_REACTING_HIGH_RIGHT,
		Reacting.QUAT_ANIMATION_REACTING_LOW_LEFT,
		Reacting.QUAT_ANIMATION_REACTING_LOW_RIGHT,
		Reacting.QUAT_ANIMATION_REACTING_HIGH_LEFT,
		Reacting.QUAT_ANIMATION_REACTING_HIGH_RIGHT,
	]
	return current_anim in reacting_animations


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		if _is_reacting_animation_playing():
			return # Ignore repeated hits while current reaction plays
		rpc("animate_hit_high_left")
