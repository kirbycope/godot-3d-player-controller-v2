extends Node3D


## Adds an [AnimationPlayer] for all child nodes of the `character` (unless one already exists) and loads animations from Mixamo.
static func animations_mixamo(character: Node3D, playback_default_blend_time = 0.0) -> void:
	#print("Setting up Mixamo animations...") # DEBUGGING
	# Iterate over each child of the `character`
	for child in character.get_children():
		var animation_player: AnimationPlayer = null
		# If the child is itself an [AnimationPlayer], then use it directly
		if child is AnimationPlayer:
			animation_player = child
		# Otherwise, check for a grandchild named "AnimationPlayer"
		else:
			animation_player = child.get_node_or_null("AnimationPlayer")
		# If no [AnimationPlayer] is found, the create one and add it
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
		#print("    AnimationPlayer added to `", child.get_path(), "`")
	#print("└── Mixamo animations setup complete.") # DEBUGGING


## Adds an [AnimationPlayer] for all child nodes of the `character` (unless one already exists) and loads animations from Quaternius.
static func animations_quaternius(character: Node3D, playback_default_blend_time = 0.0) -> void:
	#print("Setting up Quaternius animations...") # DEBUGGING
	var quaternius: AnimationLibrary = load("res://assets/universal_animation_library/AnimationLibrary_Godot.glb")
	# Iterate over each child of the `character`
	for child in character.get_children():
		var animation_player: AnimationPlayer = null
		# If the child is itself an [AnimationPlayer], then use it directly
		if child is AnimationPlayer:
			animation_player = child
		# Otherwise, check for a grandchild named "AnimationPlayer"
		else:
			animation_player = child.get_node_or_null("AnimationPlayer")
		# If no [AnimationPlayer] is found, then create one and add it
		if animation_player == null:
			animation_player = AnimationPlayer.new()
			animation_player.name = "AnimationPlayer"
			child.add_child(animation_player)
		# Configuration - Set the default blend time
		animation_player.playback_default_blend_time = playback_default_blend_time
		# Ensure the library is attached (add if not present)
		if not animation_player.has_animation_library("AnimationLibrary_Godot"):
			animation_player.add_animation_library("AnimationLibrary_Godot", quaternius)
		# Set Idle to looping and play it
		var animation : Animation = animation_player.get_animation("AnimationLibrary_Godot/Idle")
		if animation:
			animation.loop_mode = (Animation.LOOP_LINEAR)
			animation_player.play("AnimationLibrary_Godot/Idle")
		#print("    AnimationPlayer added to `", child.get_path(), "`") # DEBUGGING
	#print("└── Quaternius animations setup complete.") # DEBUGGING


## Sets up a [PhysicalBoneSimulator3D] for all child nodes of the `character`.
static func physical_bone_simulators(character: Node3D) -> void:
	#print("Setting up PhysicalBoneSimulators...") # DEBUGGING
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
	#print("└── PhysicalBoneSimulators setup complete.") # DEBUGGING
