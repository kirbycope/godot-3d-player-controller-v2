extends CanvasLayer

@onready var player: CharacterBody3D = get_parent()
@onready var panel: Panel = $Panel
@onready var vsync_button: CheckButton = panel.get_node("VBoxContainer/VSYNC")
@onready var msaa_button: OptionButton = panel.get_node("VBoxContainer/MSAA")
@onready var ssaa_button: OptionButton = panel.get_node("VBoxContainer/SSAA")
@onready var fxaa_button: CheckButton = panel.get_node("VBoxContainer/FXAA")
@onready var taa_button: CheckButton = panel.get_node("VBoxContainer/TAA")
@onready var fsr_button: OptionButton = panel.get_node("VBoxContainer/FSR")
@onready var back: Button = panel.get_node("VBoxContainer/BACK")


## Change the VSYNC value.
func _on_vsync_toggled(toggled_on: bool) -> void:
	# Check if the VSYNC option is toggled on
	if toggled_on:
		# Enable VYSNC
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	# The VSYNC option is toggled off
	else:
		# Disable VYSNC
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


## Change the MSAA value.
func _on_msaa_item_selected(index: int) -> void:
	# Map index to MSAA values: 0=Off, 1=2x, 2=4x, 3=8x
	var msaa_values = [
		RenderingServer.VIEWPORT_MSAA_DISABLED,
		RenderingServer.VIEWPORT_MSAA_2X,
		RenderingServer.VIEWPORT_MSAA_4X,
		RenderingServer.VIEWPORT_MSAA_8X,
	]
	# Apply to the current viewport
	get_viewport().set_msaa_3d(msaa_values[index])


## Change the SSAA value.
func _on_ssaa_item_selected(index: int) -> void:
	# Map index to scale factors: 0=Off (1.0), 1=1.5 (2.25× SSAA), 2=2.0 (4× SSAA)
	var scale_factors = [
		1.0,
		1.5,
		2.0,
	]
	# Get the current viewport
	var viewport = get_viewport()
	# Set the 3D scaling mode to bilinear (0)
	viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	# Apply the 3D scaling factor for SSAA
	viewport.scaling_3d_scale = scale_factors[index]


## Change the FXAA value.
func _on_fxaa_toggled(toggled_on: bool) -> void:
	# Get the current viewport
	var viewport = get_viewport()
	# Check if the FXAA option is toggled on
	if toggled_on:
		# Enable FXAA
		viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	# The FXAA option is toggled off
	else:
		# Disable FXAA
		viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED


## Change the SSRL value.
func _on_ssrl_toggled(toggled_on: bool) -> void:
	# Set the screen-space roughness limiter
	RenderingServer.screen_space_roughness_limiter_set_active(toggled_on, 0.25, 0.18)


## Change the TAA value.
func _on_taa_toggled(toggled_on: bool) -> void:
	# Get the current viewport
	var viewport = get_viewport()
	# Apply the Temporal Anti-Aliasing setting
	viewport.use_taa = toggled_on


## Change the FSR value.
func _on_fsr_item_selected(index: int) -> void:
	# Get the current viewport
	var viewport = get_viewport()
	# Apply the FSR mode based on the selected index
	viewport.scaling_3d_mode = index


## Return to the pause menu.
func _on_back_pressed():
	player.pause._on_settings_pressed()
	player.pause.resume_button.grab_focus()
