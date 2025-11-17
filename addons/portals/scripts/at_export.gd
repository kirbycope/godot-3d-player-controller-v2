class_name AtExport extends Object

## Helper class for defining custom export inspector.
##
## Intended usage is when using [method Object._get_property_list] to define a custom editor 
## inspector. The list not exhaustive, as I didn't need every single export annotation. [br]
## [codeblock]
## @export var foo: int = 0
## [/codeblock]
## becomes
## [codeblock]
## var foo: int = 0
## 
## func _get_property_list() -> void:
##     return [
##         AtExport.int_("health")
##     ]
## [/codeblock]
## Coincidentally, the dictionaries used to register [ProjectSettings] are very similar,
## too.


static func _base(propname: String, type: int) -> Dictionary:
	return {
		"name": propname,
		"type": type,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
	}

## Replacement for [annotation @GDScript.@export_tool_button]
static func button(propname: String, button_text: String, button_icon: String = "Callable") -> Dictionary:
	var result := _base(propname, TYPE_CALLABLE)
	
	assert(not button_text.contains(","), "Button text cannot contain a comma")
	
	result["hint"] = PROPERTY_HINT_TOOL_BUTTON
	result["hint_string"] = button_text + "," + button_icon
	
	return result

## [annotation @GDScript.@export] bool variables
static func bool_(propname: String, group_enable: bool = false) -> Dictionary:
	var result := _base(propname, TYPE_BOOL)
	if group_enable:
		result["hint"] = PROPERTY_HINT_GROUP_ENABLE
	return result

## [annotation @GDScript.@export] [Color] variables
static func color(propname: String) -> Dictionary:
	return _base(propname, TYPE_COLOR)


## Replacement for [annotation @GDScript.@export_color_no_alpha]
static func color_no_alpha(propname: String) -> Dictionary:
	var result := _base(propname, TYPE_COLOR)
	result["hint"] = PROPERTY_HINT_COLOR_NO_ALPHA
	return result

## Exporting an enum variable.[br]Example:
## [codeblock]
## var view_direction: ViewDirection
## # ...
## AtExport.enum_("view_direction", &"Portal3D.ViewDirection", ViewDirection)
## [/codeblock]
static func enum_(propname: String, parent_and_enum: StringName, enum_class: Variant) -> Dictionary:
	var result := int_(propname)
	
	result["class_name"] = parent_and_enum
	result["hint"] = PROPERTY_HINT_ENUM
	result["hint_string"] = ",".join(enum_class.keys())
	result["usage"] |= PROPERTY_USAGE_CLASS_IS_ENUM
	
	return result

## [annotation @GDScript.@export] float variables
static func float_(propname: String) -> Dictionary:
	return _base(propname, TYPE_FLOAT)

## Replacement for [annotation @GDScript.@export_range] with float variables.
## Also see [method int_range]
static func float_range(propname: String, min: float, max: float, step: float = 0.01, extra_hints: Array[String] = []) -> Dictionary:
	var result := float_(propname)
	var hint_string = "%f,%f,%f" % [min, max, step]
	
	if extra_hints.size() > 0:
		for h in extra_hints:
			hint_string += ("," + h)
	
	result["hint"] = PROPERTY_HINT_RANGE
	result["hint_string"] = hint_string
	
	return result

## [annotation @GDScript.@export] integer variables
static func int_(propname: String) -> Dictionary:
	return _base(propname, TYPE_INT)

## Replacement for [annotation @GDScript.@export_flags]
static func int_flags(propname: String, options: Array) -> Dictionary:
	var result := int_(propname)
	result["hint"] = PROPERTY_HINT_FLAGS
	result["hint_string"] = ",".join(options)
	return result

## Replacement for [annotation @GDScript.@export_flags_3d_physics]
static func int_physics_3d(propname: String) -> Dictionary:
	var result := int_(propname)
	result["hint"] = PROPERTY_HINT_LAYERS_3D_PHYSICS
	return result

## Replacement for [annotation @GDScript.@export_range] with integer variables. 
## Also see [method float_range]
static func int_range(propname: String, min: int, max: int, step: int = 1, extra_hints: Array[String] = []) -> Dictionary:
	var result := float_range(propname, min, max, step, extra_hints)
	result["type"] = TYPE_INT
	return result

## Replacement for [annotation @GDScript.@export_flags_3d_render]
static func int_render_3d(propname: String) -> Dictionary:
	var result := int_(propname)
	result["hint"] = PROPERTY_HINT_LAYERS_3D_RENDER
	return result

## Replacement for [annotation @GDScript.@export_group].
static func group(group_name: String, prefix: String = "") -> Dictionary:
	var result := _base(group_name, TYPE_NIL)
	# Overwrite the usage!
	result["usage"] = PROPERTY_USAGE_GROUP
	result["hint_string"] = prefix
	return result

## Close the group that began with [method group]. If you've supplied a prefix to [method group],
## it should close itself.
static func group_end() -> Dictionary:
	return group("")

## [annotation @GDScript.@export] NodePath variables. Variables of [i]node type[/i] also only store
## [NodePath]s.
## [codeblock]
## var mesh: MeshInstance3D
## # inside _get_property_list
## AtExport.node("mesh", "MeshInstance3D")
## [/codeblock]
static func node(propname: String, node_class: StringName) -> Dictionary:
	var result = _base(propname, TYPE_OBJECT)
	result["hint"] = PROPERTY_HINT_NODE_TYPE
	result["class_name"] = node_class
	result["hint_string"] = node_class
	return result

## [annotation @GDScript.@export] for [String] variables
static func string(propname: String) -> Dictionary:
	return _base(propname, TYPE_STRING)

## Replacement for [annotation @GDScript.@export_subgroup]. Only works when nested inside 
## [method group].
static func subgroup(subgroup_name: String, prefix: String = "") -> Dictionary:
	var result := _base(subgroup_name, TYPE_NIL)
	# Overwrite the usage!
	result["usage"] = PROPERTY_USAGE_SUBGROUP
	result["hint_string"] = prefix
	return result

## Closes a subgroup created with [method subgroup]. Also see [method group_end]
static func subgroup_end() -> Dictionary:
	return subgroup("")

## [annotation @GDScript.@export] for [Vector2] variables
static func vector2(propname: String) -> Dictionary:
	return _base(propname, TYPE_VECTOR2)

## [annotation @GDScript.@export] for [Vector3] variables
static func vector3(propname: String) -> Dictionary:
	return _base(propname, TYPE_VECTOR3)
