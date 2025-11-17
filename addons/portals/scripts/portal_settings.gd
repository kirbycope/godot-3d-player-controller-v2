class_name PortalSettings extends Object

## Static helper class for portal project settings.
##
## Features helper methods for inserting addon-related settings into [ProjectSettings].
## Used mainly in plugin initialization and for getting defaults in [Portal3D]

static func _qual_name(setting: String) -> String:
	return "addons/portals/" + setting

## Initializes a setting, it it's not present already. The setting is [i]basic[/i] by default.
static func init_setting(setting: String, 
						 default_value: Variant, 
						 requires_restart: bool = false) -> void:
	setting = _qual_name(setting)
	
	# This would mean the setting is already overriden
	if not ProjectSettings.has_setting(setting):
		ProjectSettings.set_setting(setting, default_value)
	
	ProjectSettings.set_initial_value(setting, default_value)
	ProjectSettings.set_restart_if_changed(setting, requires_restart)
	ProjectSettings.set_as_basic(setting, true)

## See companion class [class AtExport], it has some utilities which might be helpful!
static func add_info(config: Dictionary) -> void:
	var qual_name = _qual_name(config["name"])
	
	config["name"] = qual_name
	# In case this is coming from AtExport, which is geared towards inspector properties
	config.erase("usage") 
	
	ProjectSettings.add_property_info(config)

## Calls [method ProjectSettings.get_setting]
static func get_setting(setting: String) -> Variant:
	setting = _qual_name(setting)
	return ProjectSettings.get_setting(setting)
