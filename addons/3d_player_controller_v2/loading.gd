extends CanvasLayer

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var tip: Label = $Tip

var tips = [
	"Tip: Don't bother reading this, it's a waste of time.",
	"Tip: Press [Alt]+[F4] to rage quit!",
]

var _target_scene_path: String = ""
var _scene_properties: Dictionary = {}
var _scene_to_close: Node = null


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	tip.text = tips[randi() % tips.size()]


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Return early if there's no target scene to load
	if _target_scene_path == "":
		return

	# Get the status of the threaded loading
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(_target_scene_path, progress)
	# Handle <100% progress
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		progress_bar.value = progress[0] * 100
	# Handle 100% progress
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		progress_bar.value = 100
		_complete()
	# Handle failure(s)
	elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		print("Error loading scene: ", _target_scene_path) # DEBUGGING
		_target_scene_path = ""
		hide()


## Starts loading a scene from the given path with optional properties to set on the scene.
## If scene_to_close is provided, that node will be freed after loading completes.
func start(path: String, properties: Dictionary = {}, scene_to_close: Node = null) -> void:
	_target_scene_path = path
	_scene_properties = properties
	_scene_to_close = scene_to_close
	show()
	progress_bar.value = 0
	ResourceLoader.load_threaded_request(_target_scene_path)


## Completes the loading process by instantiating the scene and applying properties.
func _complete() -> void:
	var scene_resource = ResourceLoader.load_threaded_get(_target_scene_path)
	if scene_resource:
		var scene = scene_resource.instantiate()
		for key in _scene_properties:
			scene.set(key, _scene_properties[key])

		get_tree().root.add_child(scene)
		get_tree().current_scene = scene
		if _scene_to_close:
			_scene_to_close.queue_free()
	_target_scene_path = ""
