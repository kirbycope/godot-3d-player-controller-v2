extends Node3D

## -- SETUP ANIMATIONS -- 
# TSCN Example: Godette (Rigged) - https://sketchfab.com/3d-models/godette-rigged-dd05b69799a2438e97c90d166f6e416a
# This model comes with an AnimationPlayer. We will add our animation to that library.
# This is in addition to adding AnimationPlayers to any child nodes of its parent Node3D (`Rig`, `Bone_Circle`, etc.)
# ```
# Player: [CharacterBody3D] (res://addons/3d_player_controller_v2/player.tscn)
# ├── Visuals: [Node3D]
# │   └──  Character: [Character]  <--- This script
# │	  	└──  Godette: [Node3D]
# │     	└── Godette: [Node3D] (res://addons/3d_player_controller_v2/assets/characters/godette/Godette.gltf)
# │      		└── Rig: [Node3D]
# │      			└── %GeneralSkeleton: [Skeleton3D] (The Skeleton _after_ Retargeting)
# │      				└── Mesh: [MeshInstance3D]
# │      		└── AnimationPlayer: [Node3D]
# │   			└── ...
# ```

## -- SETUP PHYSICAL BONE SIMULATORS --


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup animations for all `character` components
	setup_animations(self, 0.2)

	# Setup physical bone simulators for all `character` components
	setup_physical_bone_simulators(self)


## Sets up an [AnimationPlayer] for all child nodes of the `character`.
static func setup_animations(character: Node3D, playback_default_blend_time = 0.0) -> void:
	### Animations from "quaternius.com"
	#var quaternius: AnimationLibrary = load("res://assets/universal_animation_library/AnimationLibrary_Godot.glb")
	# Add an [AnimationPlayer] to each child and attach the library
	#for child in character.get_children():
	#	var animation_player: AnimationPlayer = child.get_node_or_null("AnimationPlayer")
	#	if animation_player == null:
	#		animation_player = AnimationPlayer.new()
	#		animation_player.name = "AnimationPlayer"
	#		child.add_child(animation_player)
	#	# Ensure the library is attached (add if not present)
	#	if not animation_player.has_animation_library("AnimationLibrary_Godot"):
	#		animation_player.add_animation_library("AnimationLibrary_Godot", quaternius)
	#	# Configuration - Set the default blend time
	#	animation_player.playback_default_blend_time = playback_default_blend_time

	for child in character.get_children():
		## Animations from "mixamo.com"
		var animation_player: AnimationPlayer = null
		# If the child is itself an [AnimationPlayer] (e.g., GLTF rig root), use it directly
		if child is AnimationPlayer:
			animation_player = child
		else:
			# Otherwise look for a direct child, named "AnimationPlayer"
			animation_player = child.get_node_or_null("AnimationPlayer")
		# If no [AnimationPlayer] is found, continue this `for` loop iteration to create one
		if animation_player == null:
			animation_player = AnimationPlayer.new()
			animation_player.name = "AnimationPlayer"
			child.add_child(animation_player)
		# Configuration - Set the default blend time
		animation_player.playback_default_blend_time = playback_default_blend_time
		# Load and add animations from addons/3d_player_controller_v2/assets/animations/mixamo/
		var base_path = "res://addons/3d_player_controller_v2/assets/animations/mixamo/"
		# Dynamically get all subdirectories in the base path
		var dir = DirAccess.open(base_path)
		if dir:
			dir.list_dir_begin()
			var category = dir.get_next()
			while category != "":
				if category != "." and category != ".." and dir.current_is_dir():
					var category_path = base_path + category + "/"
					# Load all .fbx files from each category; ".../climbing/Climbing_Down.fbx" -> 'Climbing_Down' (library) > 'Climbing_Down/mixamo_com' (animation)
					var category_dir = DirAccess.open(category_path)
					if category_dir:
						category_dir.list_dir_begin()
						var file_name = category_dir.get_next()
						while file_name != "":
							if file_name.ends_with(".fbx"):
								var animation_path = category_path + file_name
								if ResourceLoader.exists(animation_path):
									var animation_lib: AnimationLibrary = load(animation_path)
									var lib_name = file_name.trim_suffix(".fbx")
									if animation_lib and not animation_player.has_animation_library(lib_name):
										animation_player.add_animation_library(lib_name, animation_lib)
							file_name = category_dir.get_next()
				category = dir.get_next()


## Sets up a [PhysicalBoneSimulator3D] for all child nodes of the `character`.
static func setup_physical_bone_simulators(character: Node3D) -> void:
	# Add a PhysicalBoneSimulator3D to each skeleton and setup bones
	for child in character.get_children():
		# Locate the skeleton; adjust the path if your rigs differ
		var skeleton: Skeleton3D = child.get_node_or_null("%GeneralSkeleton")
		if skeleton == null: continue
		# Ensure a simulator exists under the skeleton
		var simulator: PhysicalBoneSimulator3D = skeleton.get_node_or_null("PhysicalBoneSimulator3D")
		if simulator == null:
			simulator = PhysicalBoneSimulator3D.new()
			simulator.name = "PhysicalBoneSimulator3D"
			simulator.active = false
			skeleton.add_child(simulator)

		# If no physical bones exist yet, build them manually
		if simulator.get_child_count() == 0:
			var bone_count := skeleton.get_bone_count()
			for bone_idx in bone_count:
				var bone_name := skeleton.get_bone_name(bone_idx)
				var phys_bone := PhysicalBone3D.new()
				phys_bone.name = "Physical Bone " + bone_name
				phys_bone.bone_name = bone_name
				phys_bone.transform = skeleton.get_bone_global_rest(bone_idx)
				simulator.add_child(phys_bone)

				# Minimal collision so the ragdoll can interact; tune per bone later
				var shape := CollisionShape3D.new()
				shape.shape = CapsuleShape3D.new()
				phys_bone.add_child(shape)

		# Leave simulation disabled; ragdoll state toggles it
		simulator.active = false
