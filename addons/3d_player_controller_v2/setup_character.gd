extends Node3D
class_name SetupCharacter
## 🧑‍🔧 Sets up a character with animations.


## Adds animation libraries to the character and sets flags on the `player` to indicate which sets are available.
static func add_animations(character: Node3D, player: CharacterBody3D) -> void:
	# https://www.mixamo.com/#/
	animations_mixamo(character, 0.2)
	if player:
		pass # placeholder

	# https://quaternius.com/packs/universalanimationlibrary.html
	if ResourceLoader.exists("res://assets/universal_animation_library/UAL1.glb"):
		animations_quaternius(character, 0.2)
		if player:
			pass # placeholder

	# https://quaternius.com/packs/universalanimationlibrary2.html
	if ResourceLoader.exists("res://assets/universal_animation_library_2/UAL2.glb"):
		animations_quaternius_2(character, 0.2)
		if player:
			pass # placeholder


## Adds an [AnimationPlayer] for all child nodes of the `character` (unless one already exists) and loads animations from Mixamo.
static func animations_mixamo(character: Node3D, playback_default_blend_time: float = 0.0) -> void:
	#print(  "Setting up Mixamo animations...") # DEBUGGING
	# Iterate over each child of the `character`
	for child in character.get_children():
		# Find or create an AnimationPlayer under the child (character.child.child)
		var animation_player: AnimationPlayer = _find_or_create_animation_player(child, playback_default_blend_time)
		if animation_player != null:
			# Load and add animations from the source directory
			var base_path = "res://addons/3d_player_controller_v2/assets/animations/mixamo/"
			# Check if the mixamo directory exists
			var dir = DirAccess.open(base_path)
			#print(  "│  Checking for subdirectories in in path: `/", base_path, "`...") # DEBUGGING
			if dir:
				# Iterate over each category (subfolder); '/climbing', '/crawling', etc.
				dir.list_dir_begin()
				# Get the next category in the base directory (which would be the first on the first call)
				var category = dir.get_next()
				while category != "":
					if category != "." \
					and category != ".." \
					and dir.current_is_dir() \
					and not category.contains(".import") \
					and not category.to_lower().contains(".fbx"):
						#print(  "│  Checking for animations in subdirectory: `/", category, "`...") # DEBUGGING
						# Define the path to the category
						var category_path = base_path + category + "/"
						var dir2 = DirAccess.open(category_path)
						# Check if the category directory exists
						var category_dir = DirAccess.open(category_path)
						if category_dir:
							# Iterate over each .fbx file in the category
							category_dir.list_dir_begin()
							var file_name = category_dir.get_next()
							while file_name != "":
								# Look for the import file, which shares the name of the original .fbx
								if file_name.ends_with(".fbx.import"):
									file_name = file_name.trim_suffix(".import") # Remove the .import suffix to get the original file name
									#print(  "│    Found animation: `/", file_name, "`") # DEBUGGING
									var animation_path = category_path + file_name
									#print(  "│    Loading animation resource from path: `", animation_path, "`") # DEBUGGING
									if ResourceLoader.exists(animation_path):
										var animation_lib: AnimationLibrary = load(animation_path)
										var lib_name = file_name.trim_suffix(".fbx")
										if animation_lib and not animation_player.has_animation_library(lib_name):
											animation_player.add_animation_library(lib_name, animation_lib)
											#print(  "│    Added Mixamo animation library: `", lib_name, "`") # DEBUGGING
								# Get the next file in the category directory, for the next iteration
								file_name = category_dir.get_next()
					# Get the next category in the base directory, for the next iteration
					category = dir.get_next()
	#print(  "└── Mixamo animations setup complete.") # DEBUGGING


## Adds an [AnimationPlayer] for all child nodes of the `character` (unless one already exists) and loads animations from Quaternius.
static func animations_quaternius(character: Node3D, playback_default_blend_time: float = 0.0) -> void:
	#print(  "Setting up Quaternius animations...") # DEBUGGING
	# Iterate over each child of the `character`
	for child in character.get_children():
		# Find or create an AnimationPlayer under the child (character.child.child)
		var animation_player: AnimationPlayer = _find_or_create_animation_player(child, playback_default_blend_time)
		if animation_player != null:
			var quaternius: AnimationLibrary = load("res://assets/universal_animation_library/UAL1.glb")
			# Ensure the library is attached (add if not present)
			if not animation_player.has_animation_library("UAL1"):
				animation_player.add_animation_library("UAL1", quaternius)
				#print(  "│    Added Quaternius' `UAL1` animation library") # DEBUGGING
		#print(  "└── Quaternius animations setup complete.") # DEBUGGING


## Adds an [AnimationPlayer] for all child nodes of the `character` (unless one already exists) and loads animations from Quaternius.
static func animations_quaternius_2(character: Node3D, playback_default_blend_time: float = 0.0) -> void:
	#print(  "Setting up Quaternius 2 animations...") # DEBUGGING
	# Iterate over each child of the `character`
	for child in character.get_children():
		# Find or create an AnimationPlayer under the child (character.child.child)
		var animation_player: AnimationPlayer = _find_or_create_animation_player(child, playback_default_blend_time)
		if animation_player != null:
			var quaternius_2: AnimationLibrary = load("res://assets/universal_animation_library_2/UAL2.glb")
			if not animation_player.has_animation_library("UAL2"):
				animation_player.add_animation_library("UAL2", quaternius_2)
				#print(  "│    Added Quaternius' `UAL2` animation library") # DEBUGGING
	#print(  "└── Quaternius animations setup complete.") # DEBUGGING


## Helper to find or create an [AnimationPlayer] under the given `character.child`.
static func _find_or_create_animation_player(child: Node, playback_default_blend_time: float = 0.0) -> AnimationPlayer:
	var animation_player: AnimationPlayer = null
	# If the child is itself an [AnimationPlayer], then use it directly
	if child is AnimationPlayer:
		animation_player = child
		if animation_player != null:
			animation_player.playback_default_blend_time = playback_default_blend_time
			#print(  "│    Found existing (character.child) AnimationPlayer in `", animation_player.get_path(), "`") # DEBUGGING
	# Otherwise, check for a grandchild named "AnimationPlayer"
	else:
		animation_player = child.get_node_or_null("AnimationPlayer")
		if animation_player != null:
			animation_player.playback_default_blend_time = playback_default_blend_time
			#print(  "│    Found existing (character.child.child) AnimationPlayer in `", animation_player.get_path(), "`") # DEBUGGING
	# If no [AnimationPlayer] is found, the create one and add it to the current character.child
	if animation_player == null:
		animation_player = AnimationPlayer.new()
		animation_player.name = "AnimationPlayer"
		child.add_child(animation_player)
		animation_player.playback_default_blend_time = playback_default_blend_time
		#print(  "│    Created new (character.child.child) AnimationPlayer in `", animation_player.get_path(), "`") # DEBUGGING
	return animation_player
