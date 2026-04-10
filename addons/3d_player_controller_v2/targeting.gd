extends Node
class_name Targeting

var targets = {}
var current_locked_target: Node3D = null ## The current locked target
var current_selected_target: Node3D = null ## The current selected target
var previous_active_target: Node3D = null

var look_target: Marker3D
var look_at_modifiers: Array[LookAtModifier3D] = []

@onready var player: CharacterBody3D = get_parent()


func _ready() -> void:
	# Create a proxy target for look-at offsetting.
	look_target = Marker3D.new()
	look_target.name = "LookTarget"
	add_child(look_target)
	# Wait one frame so player skeleton data is initialized...
	await get_tree().process_frame
	# setup bone look at modifiers for player to look at locked on target
	for skeleton in player.skeletons():
		if skeleton is Skeleton3D:
			var modifier = LookAtModifier3D.new()
			modifier.name = "LookAtModifier3D"
			modifier.bone_name = player.bone_name_head
			modifier.active = false
			modifier.duration = 0.3
			modifier.use_angle_limitation = true
			modifier.primary_limit_angle = deg_to_rad(90.0)
			modifier.secondary_limit_angle = deg_to_rad(60.0)
			skeleton.add_child(modifier)
			modifier.target_node = modifier.get_path_to(look_target)
			look_at_modifiers.append(modifier)


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Do nothing if the "pause" menu is visible
	if player.pause.visible: return

	# Clear targets on 'button_9' press
	if event.is_action_pressed(Controls.BUTTON_9):
		if current_locked_target:
			unlock_target(current_locked_target)
		if current_selected_target:
			deselect_target()


func _unhandled_input(event: InputEvent) -> void:
	# If a left click makes it here, no UI Control consumed it.
	# We deselect first; if the click actually hit a target, physics picking
	# will run _on_target_click_detection_input_event and immediately re-select it.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if current_selected_target:
			#print("Deselecting target due to click on empty space") # DEBUGGING
			deselect_target()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var active_target = current_locked_target if current_locked_target else current_selected_target

	if active_target != previous_active_target:
		previous_active_target = active_target

	if active_target:
		var look_at_marker = active_target.get_node_or_null("LookAtMarker")
		if look_at_marker:
			look_target.global_position = look_at_marker.global_position
			for modifier in look_at_modifiers:
				if is_instance_valid(modifier):
					modifier.active = true
	else:
		for modifier in look_at_modifiers:
			if is_instance_valid(modifier):
				modifier.active = false


## Finds the player's nearest target (if any) and returns it.
func find_nearest_target(distance_threshold: float) -> Node:
	# Create a variable to track the nearest target found
	var nearest_target = null
	# Set the distance threshold for finding targets (adjust as needed)
	var nearest_distance = distance_threshold
	# Iterate through player's targets (if any)
	for target in targets.values():
		# Get the distance from the `player` to this `target`
		var distance = player.global_transform.origin.distance_to(target.global_transform.origin)
		# Check if this `target` is closer than the previously found target
		if distance < nearest_distance:
			# Update nearest_distance to be the distance to this `target`
			nearest_distance = distance
			# Update nearest_target to be this `target`
			nearest_target = target
	# Return the nearest target found (or null if no targets within threshold)
	return nearest_target


## Highlights a target by changing its LockedTargetIndicator to Color.YELLOW.
func highlight_target_material(target: Node3D) -> void:
	var indicator = target.get_node_or_null("LockedTargetIndicator")
	if indicator:
		var mesh_instance = indicator.get_node_or_null("MeshInstance3D")
		if mesh_instance and mesh_instance is MeshInstance3D:
			var current_material = mesh_instance.get_active_material(0)
			if current_material:
				var highlighted_material = current_material.duplicate()
				if highlighted_material is StandardMaterial3D:
					highlighted_material.albedo_color = Color.YELLOW
				mesh_instance.set_surface_override_material(0, highlighted_material)


## "Selects" a target.
func select_target(target: Node3D) -> void:
	if current_selected_target != target:
		if current_selected_target:
			deselect_target()
		current_selected_target = target
		highlight_target_material(current_selected_target)
		if "health_bar" in current_selected_target and current_selected_target.health_bar:
			current_selected_target.health_bar.visible = true


## "Deselects" the current target.
func deselect_target() -> void:
	if current_selected_target:
		if current_selected_target != current_locked_target:
			reset_target_material(current_selected_target)
		if "health_bar" in current_selected_target and current_selected_target.health_bar:
			current_selected_target.health_bar.visible = false
		current_selected_target = null


## "Locks" onto a target.
func lock_target(target: Node3D) -> void:
	# Flag the player as "target locked"
	player.is_target_locked = true
	# Update the current "locked target" [Node]
	current_locked_target = target
	# Change the current "locked target" indicator's material to Color.YELLOW
	highlight_target_material(current_locked_target)
	select_target(target)
	var indicator = target.get_node_or_null("LockedTargetIndicator")
	if indicator:
		indicator.show()


## Resets a target's LockedTargetIndicator to Color.WHITE.
func reset_target_material(target: Node3D) -> void:
	var indicator = target.get_node_or_null("LockedTargetIndicator")
	if indicator:
		var mesh_instance = indicator.get_node_or_null("MeshInstance3D")
		if mesh_instance and mesh_instance is MeshInstance3D:
			mesh_instance.set_surface_override_material(0, null)


## Removes a target from targeting state/caches and cleans related connections and UI markers.
func remove_target(target: Node3D) -> void:
	if target == null:
		return

	targets.erase(target.get_instance_id())

	# Disconnect from the target's ClickDetection input_event.
	var click_detection = target.get_node_or_null("ClickDetection")
	if click_detection:
		var click_callable = _on_target_click_detection_input_event.bind(target)
		if click_detection.input_event.is_connected(click_callable):
			click_detection.input_event.disconnect(click_callable)

	# Unlock/deselect any active state on this target.
	if current_locked_target == target:
		unlock_target(target)
	if current_selected_target == target:
		deselect_target()

	# Remove the lock indicator instance from the target.
	var indicator = target.get_node_or_null("LockedTargetIndicator")
	if indicator:
		indicator.queue_free()


## "Unlocks" the player from a target.
func unlock_target(target: Node3D) -> void:
	# Flag the player as not "target locked"
	player.is_target_locked = false
	
	# Store a reference before we clear it
	var previous_locked_target = current_locked_target
	
	# Set the current "locked target" to null
	current_locked_target = null

	var indicator = target.get_node_or_null("LockedTargetIndicator")
	if indicator:
		indicator.hide()

	# Deselect if it was the same as the selected target, otherwise just reset the material
	if previous_locked_target:
		if current_selected_target == previous_locked_target:
			deselect_target()
		else:
			# Change the current "locked target" indicator's material to Color.WHITE
			reset_target_material(previous_locked_target)


func _on_target_click_detection_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int, target: Node3D) -> void:
	# Do nothing if the "pause" menu is visible
	if player and player.pause.visible:
		return

	# Click to select target
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			select_target(target)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			pass
			#print("Auto-attacking target: " + target.name) # TODO


func _on_enemy_detection_body_entered(body: Node3D) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Check if the [Node] that entered the detection area is in the "Focusable" group
	if body.is_in_group("Focusable"):
		# Add [Node] to the `targets` list
		targets[body.get_instance_id()] = body
		
		# Connect to the target's ClickDetection input_event to handle locking on
		var click_detection = body.get_node_or_null("ClickDetection")
		if click_detection:
			var click_callable = _on_target_click_detection_input_event.bind(body)
			if not click_detection.input_event.is_connected(click_callable):
				click_detection.input_event.connect(click_callable)
		
		# Check if "locked target" indicator doesn't already exist
		if body.get_node_or_null("LockedTargetIndicator") == null:
			# Duplicate the indicator instance attached to the `player`
			var indicator_instance = player.locked_target_indicator.duplicate()
			# Add the duplicated instance as a child of the detected body
			body.add_child(indicator_instance)


func _on_enemy_detection_body_exited(body: Node3D) -> void:
	# Do nothing if not the authority
	if not is_multiplayer_authority(): return

	# Check if the [Node] that entered the detection area is in the "Focusable" group
	if body.is_in_group("Focusable"):
		remove_target(body)
