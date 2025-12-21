extends CanvasLayer
## Manages input mapping for controller, keyboard/mouse, and touch controls with dynamic InputMap setup

enum InputType {
	CONTROLLER,
	KEYBOARD_MOUSE,
	TOUCH,
}

var last_input_type: InputType

@export var button_0 = "button_0" 		## Key: Space, Controller: Ⓐ (Microsoft), Ⓑ (Nintendo), ⮾ (Sony)
@export var button_1 = "button_1" 		## Key: Shift, Controller: Ⓑ (Microsoft), Ⓐ (Nintendo), 🄋 (Sony)
@export var button_2 = "button_2" 		## Key: E, Controller: Ⓧ (Microsoft), Ⓨ (Nintendo), 🟗 (Sony)
@export var button_3 = "button_3" 		## Key: Ctrl, Controller: Ⓨ (Microsoft), Ⓧ (Nintendo), 🟕 (Sony)
@export var button_4 = "button_4"		## Key: Mouse Button 0 (left click), Controller: 🄻1
@export var button_5 = "button_5"		## Key: Mouse Button 1 (right click), Controller: 🅁1
@export var button_6 = "button_6"		## Key: Mouse Button 3 (forward), Controller: 🄻2
@export var button_7 = "button_7"		## Key: Mouse Button 4 (backward), Controller: 🅁2
@export var button_8 = "button_8"		## Key: F5, Controller: ⧉ (Microsoft), ⊖ (Nintendo), ⧉ (Sony)
@export var button_9 = "button_9"		## Key: Esc, Controller: ☰ (Microsoft), ⊕ (Nintendo), ☰ (Sony)
@export var button_10 = "button_10"		## Key: Mouse scroll up, Controller: Ⓛ3
@export var button_11 = "button_11"		## Key: Mouse scroll down, Controller: Ⓡ3
@export var button_12 = "button_12"		## Key: Tab, Controller: D-Pad Up
@export var button_13 = "button_13"		## Key: Q, Controller: D-Pad Down
@export var button_14 = "button_14"		## Key: B,Controller: D-Pad Left
@export var button_15 = "button_15"		## Key: T, Controller: D-Pad Right
@export var screenshot = "screenshot"	## Key: F2, Controller: N/A
@export var debug = "debug"				## Key: F3, Controller: N/A
@export var look_down = "look_down"		## Key: Down Arrow, Controller: Right Stick Down
@export var look_left = "look_left"		## Key: Left Arrow, Controller: Right Stick Left
@export var look_right = "look_right"	## Key: Right Arrow, Controller: Right Stick Right
@export var look_up = "look_up"			## Key: Up Arrow, Controller: Right Stick Up
@export var move_down = "move_down"		## Key: S, Controller: Left Stick Down
@export var move_left = "move_left"		## Key: A, Controller: Left Stick Left
@export var move_right = "move_right"	## Key: D, Controller: Left Stick Right
@export var move_up = "move_up"			## Key: W, Controller: Left Stick Up

@onready var mobile: Control = $Mobile
@onready var joystick_left: Control = mobile.get_node("JoystickLeft")
@onready var joystick_right: Control = mobile.get_node("JoystickRight")
@onready var joy_circle_left_texture_rect: TextureRect = joystick_left.get_node("JoyCircleLeft/TextureRect") ## The left-analog stick top
@onready var joy_circle_right_texture_rect: TextureRect = joystick_right.get_node("JoyCircleRight/TextureRect") ## The left-analog stick top

var joystick_left_offset := Vector2.ZERO ## The normalized offset of the left joystick for movement input
var joy_circle_left_texture_center := Vector2.ZERO ## The "center" of the left joystick texture. Example; 128px x 128px = Vector2(64.0, 64.0)
var joy_circle_left_texture_position := Vector2.ZERO ## The center position of the left-joystick texture

var joystick_right_offset := Vector2.ZERO ## The normalized offset of the right joystick for camera movement
var joy_circle_right_texture_center := Vector2.ZERO ## The "center" of the right joystick texture. Example; 128px x 128px = Vector2(64.0, 64.0)
var joy_circle_right_texture_position := Vector2.ZERO ## The center position of the right-joystick texture

var left_touch_index := -1
var right_touch_index := -1


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# By default, hide the mobile controls UI
	mobile.hide()

	# Get initial dimensions of the left joystick
	joy_circle_left_texture_center = Vector2(joy_circle_left_texture_rect.size.x / 2, joy_circle_left_texture_rect.size.y / 2)
	joy_circle_left_texture_position = joystick_left.position + joy_circle_left_texture_center
	# Get initial dimensions of the right joystick
	joy_circle_right_texture_center = Vector2(joy_circle_right_texture_rect.size.x / 2, joy_circle_right_texture_rect.size.y / 2)
	joy_circle_right_texture_position = joystick_right.position + joy_circle_right_texture_center

	# Check if [debug] action is not in the Input Map
	if not InputMap.has_action(debug):
		# Add the [debug] action to the Input Map
		InputMap.add_action(debug)
		# Keyboard [F3]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_F3
		InputMap.action_add_event(debug, key_event)
	# Check if [screenshot] action is not in the Input Map
	if not InputMap.has_action(screenshot):
		# Add the [screenshot] action to the Input Map
		InputMap.add_action(screenshot)
		# Keyboard [F2]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_F2
		InputMap.action_add_event(screenshot, key_event)
	# Check if [move_down] action is not in the Input Map
	if not InputMap.has_action(move_down):
		# Add the [move_down] action to the Input Map
		InputMap.add_action(move_down)
		# Keyboard 🅂
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_S
		InputMap.action_add_event(move_down, key_event)
		# Controller [left-stick, backward]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_LEFT_Y
		joystick_event.axis_value = 1.0
		InputMap.action_add_event(move_down, joystick_event)
	# Check if [move_left] action is not in the Input Map
	if not InputMap.has_action(move_left):
		# Add the [move_left] action to the Input Map
		InputMap.add_action(move_left)
		# Keyboard 🄰
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_A
		InputMap.action_add_event(move_left, key_event)
		# Controller [left-stick, left]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_LEFT_X
		joystick_event.axis_value = -1.0
		InputMap.action_add_event(move_left, joystick_event)
	# Check if [move_right] action is not in the Input Map
	if not InputMap.has_action(move_right):
		# Add the [move_right] action to the Input Map
		InputMap.add_action(move_right)
		# Keyboard 🄳
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_D
		InputMap.action_add_event(move_right, key_event)
		# Controller [left-stick, right]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_LEFT_X
		joystick_event.axis_value = 1.0
		InputMap.action_add_event(move_right, joystick_event)
	# Check if [move_up] action is not in the Input Map
	if not InputMap.has_action(move_up):
		# Add the [move_up] action to the Input Map
		InputMap.add_action(move_up)
		# Keyboard 🅆
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_W
		InputMap.action_add_event(move_up, key_event)
		# Controller [left-stick, forward]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_LEFT_Y
		joystick_event.axis_value = -1.0
		InputMap.action_add_event(move_up, joystick_event)
	# Check if [look_up] action is not in the Input Map
	if not InputMap.has_action(look_up):
		# Add the [look_up] action to the Input Map
		InputMap.add_action(look_up)
		# Keyboard ⍐
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_UP
		InputMap.action_add_event(look_up, key_event)
		# Controller [right-stick, up]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_RIGHT_Y
		joystick_event.axis_value = -1.0
		InputMap.action_add_event(look_up, joystick_event)
	# Check if [look_left] action is not in the Input Map
	if not InputMap.has_action(look_left):
		# Add the [look_left] action to the Input Map
		InputMap.add_action(look_left)
		# Keyboard ⍇
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_LEFT
		InputMap.action_add_event(look_left, key_event)
		# Controller [right-stick, left]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_RIGHT_X
		joystick_event.axis_value = -1.0
		InputMap.action_add_event(look_left, joystick_event)
	# Check if [look_down] action is not in the Input Map
	if not InputMap.has_action(look_down):
		# Add the [look_down] action to the Input Map
		InputMap.add_action(look_down)
		# Keyboard ⍗
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_DOWN
		InputMap.action_add_event(look_down, key_event)
		# Controller [right-stick, down]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_RIGHT_Y
		joystick_event.axis_value = 1.0
		InputMap.action_add_event(look_down, joystick_event)
	# Check if [look_right] action is not in the Input Map
	if not InputMap.has_action(look_right):
		# Add the [look_right] action to the Input Map
		InputMap.add_action(look_right)
		# Keyboard ⍈
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_RIGHT
		InputMap.action_add_event(look_right, key_event)
		# Controller [right-stick, right]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_RIGHT_X
		joystick_event.axis_value = 1.0
		InputMap.action_add_event(look_right, joystick_event)
	# Ⓐ Check if [button_0] action is not in the Input Map
	if not InputMap.has_action(button_0):
		# Add the [button_0] action to the Input Map
		InputMap.add_action(button_0)
		# Keyboard [Space]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_SPACE
		InputMap.action_add_event(button_0, key_event)
		# Controller Ⓐ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_A
		InputMap.action_add_event(button_0, joypad_button_event)
		# [Hack] for settings menu(s)
		InputMap.action_add_event("ui_accept", joypad_button_event)
	# Ⓑ Check if [button_1] action is not in the Input Map
	if not InputMap.has_action(button_1):
		# Add the [button_1] action to the Input Map
		InputMap.add_action(button_1)
		# Keyboard [Shift]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_SHIFT
		InputMap.action_add_event(button_1, key_event)
		# Controller Ⓑ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_B
		InputMap.action_add_event(button_1, joypad_button_event)
		# [Hack] for settings menu(s)
		InputMap.action_add_event("ui_cancel", joypad_button_event)
	# Ⓧ Check if [button_2] action is not in the Input Map
	if not InputMap.has_action(button_2):
		# Add the [button_2] action to the Input Map
		InputMap.add_action(button_2)
		# Keyboard [E]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_E
		InputMap.action_add_event(button_2, key_event)
		# Controller Ⓧ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_X
		InputMap.action_add_event(button_2, joypad_button_event)
	# Ⓨ Check if [button_3] action is not in the Input Map
	if not InputMap.has_action(button_3):
		# Add the [button_3] action to the Input Map
		InputMap.add_action(button_3)
		# Keyboard [Ctrl]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_CTRL
		InputMap.action_add_event(button_3, key_event)
		# Controller Ⓨ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_Y
		InputMap.action_add_event(button_3, joypad_button_event)
	# 🄻1 Check if [button_4] action is not in the Input Map
	if not InputMap.has_action(button_4):
		# Add the [button_4] action to the Input Map
		InputMap.add_action(button_4)
		# Mouse [left-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_LEFT
		mouse_button_event.pressed = true
		InputMap.action_add_event(button_4, mouse_button_event)
		# Controller 🄻1
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_LEFT_SHOULDER
		InputMap.action_add_event(button_4, joypad_button_event)
	# 🅁1 Check if [button_5] action is not in the Input Map
	if not InputMap.has_action(button_5):
		# Add the [button_5] action to the Input Map
		InputMap.add_action(button_5)
		# Mouse [right-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_RIGHT
		mouse_button_event.pressed = true
		InputMap.action_add_event(button_5, mouse_button_event)
		# Controller 🅁1
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_RIGHT_SHOULDER
		mouse_button_event.pressed = true
		InputMap.action_add_event(button_5, joypad_button_event)
	# 🄻2 Check if [button_6] action is not in the Input Map
	if not InputMap.has_action(button_6):
		# Add the [button_6] action to the Input Map
		InputMap.add_action(button_6)
		# Mouse [forward-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_XBUTTON2
		mouse_button_event.pressed = true
		InputMap.action_add_event(button_6, mouse_button_event)
		# Controller 🄻2
		var joypad_axis_event = InputEventJoypadMotion.new()
		joypad_axis_event.axis = JOY_AXIS_TRIGGER_LEFT
		joypad_axis_event.axis_value = 1.0
		InputMap.action_add_event(button_6, joypad_axis_event)
	# 🅁2 Check if [button_7] action is not in the Input Map
	if not InputMap.has_action(button_7):
		# Add the [button_7] action to the Input Map
		InputMap.add_action(button_7)
		# Mouse [back-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_XBUTTON1
		mouse_button_event.pressed = true
		InputMap.action_add_event(button_7, mouse_button_event)
		# Controller 🅁2
		var joypad_axis_event = InputEventJoypadMotion.new()
		joypad_axis_event.axis = JOY_AXIS_TRIGGER_RIGHT
		joypad_axis_event.axis_value = 1.0
		InputMap.action_add_event(button_7, joypad_axis_event)
	# (select) Check if [button_8] action is not in the Input Map
	if not InputMap.has_action(button_8):
		# Add the [button_8] action to the Input Map
		InputMap.add_action(button_8)
		# Keyboard [F5]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_F5
		InputMap.action_add_event(button_8, key_event)
		# Controller ⧉
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_BACK
		InputMap.action_add_event(button_8, joypad_button_event)
	# (start) Check if [button_9] action is not in the Input Map
	if not InputMap.has_action(button_9):
		# Add the [start] action to the Input Map
		InputMap.add_action(button_9)
		# Keyboard [Esc]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_ESCAPE
		InputMap.action_add_event(button_9, key_event)
		# Controller ☰
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_START
		InputMap.action_add_event(button_9, joypad_button_event)
	# Ⓛ3 Check if [button_10] action
	if not InputMap.has_action(button_10):
		# Add the [button_10] action to the Input Map
		InputMap.add_action(button_10)
		# Mouse [scroll-up]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_WHEEL_DOWN
		mouse_button_event.pressed = true
		InputMap.action_add_event(button_10, mouse_button_event)
		# Controller 🄻3
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_LEFT_STICK
		InputMap.action_add_event(button_10, joypad_button_event)
	# Ⓡ3 Check if [button_11] action
	if not InputMap.has_action(button_11):
		# Add the [button_11] action to the Input Map
		InputMap.add_action(button_11)
		# Mouse [scroll-up]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_WHEEL_UP
		mouse_button_event.pressed = true
		InputMap.action_add_event(button_11, mouse_button_event)
		# Controller 🄻3
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_RIGHT_STICK
		InputMap.action_add_event(button_11, joypad_button_event)
	# Check if [button_12] action is not in the Input Map
	if not InputMap.has_action(button_12):
		# Add the [button_12] action to the Input Map
		InputMap.add_action(button_12)
		# Controller [dpad, up]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_UP
		InputMap.action_add_event(button_12, joypad_button_event)
		# Keyboard [TAB]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_TAB
		InputMap.action_add_event(button_12, key_event)
	# Check if [button_13] action is not in the Input Map
	if not InputMap.has_action(button_13):
		# Add the [button_13] action to the Input Map
		InputMap.add_action(button_13)
		# Controller [dpad, down]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_DOWN
		InputMap.action_add_event(button_13, joypad_button_event)
		# Keyboard [Q]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_Q
		InputMap.action_add_event(button_13, key_event)
	# Check if [button_14] action is not in the Input Map
	if not InputMap.has_action(button_14):
		# Add the [button_14] action to the Input Map
		InputMap.add_action(button_14)
		# Controller [dpad, left]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_LEFT
		InputMap.action_add_event(button_14, joypad_button_event)
		# Keyboard [B]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_B
		InputMap.action_add_event(button_14, key_event)
	# Check if [button_15] action is not in the Input Map
	if not InputMap.has_action(button_15):
		# Add the [button_15] action to the Input Map
		InputMap.add_action(button_15)
		# Controller [dpad, right]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_RIGHT
		InputMap.action_add_event(button_15, joypad_button_event)
		# Keyboard [T]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_T
		InputMap.action_add_event(button_15, key_event)


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton \
	or event is InputEventJoypadMotion:
		last_input_type = InputType.CONTROLLER
	if event is InputEventKey \
	or event is InputEventMouseButton \
	or event is InputEventMouseMotion:
		last_input_type = InputType.KEYBOARD_MOUSE
	if event is InputEventScreenDrag \
	or event is InputEventScreenTouch:
		last_input_type = InputType.TOUCH

		# Handle [initial] "touch" input for mobile joystick(s)
		if event is InputEventScreenTouch:
			var touch := event as InputEventScreenTouch
			if touch.pressed:
				if left_touch_index == -1 and _is_on_left_knob(touch.position):
					left_touch_index = touch.index
				elif right_touch_index == -1 and _is_on_right_knob(touch.position):
					right_touch_index = touch.index
			else:
				if touch.index == left_touch_index:
					_reset_left_touch()
					left_touch_index = -1
				if touch.index == right_touch_index:
					_reset_right_touch()
					right_touch_index = -1

		# Handle "drag" input for mobile joystick(s)
		elif event is InputEventScreenDrag:
			var drag := event as InputEventScreenDrag
			if drag.index == left_touch_index:
				_handle_left_touch(drag.position)
			if drag.index == right_touch_index:
				_handle_right_touch(drag.position)

	# Show/hide mobile controls based on last input type
	mobile.visible = last_input_type == InputType.TOUCH


## Helper function to check if a position is on the left joystick knob.
func _is_on_left_knob(p: Vector2) -> bool:
	var rect := Rect2(joy_circle_left_texture_rect.global_position, joy_circle_left_texture_rect.size)
	return rect.has_point(p)


## Helper function to check if a position is on the right joystick knob.
func _is_on_right_knob(p: Vector2) -> bool:
	var rect := Rect2(joy_circle_right_texture_rect.global_position, joy_circle_right_texture_rect.size)
	return rect.has_point(p)


## Helper function to handle left joystick touch input.
func _handle_left_touch(pos: Vector2) -> void:
	# Calculate the difference between the touch position and the center of the joystick's inital position
	joystick_left_offset = pos - joy_circle_left_texture_position
	# Check if the offset exceeds the joystick's radius
	if joystick_left_offset.length() > joy_circle_left_texture_center.x:
		# Clamp the offset to the joystick's radius
		joystick_left_offset = joystick_left_offset.normalized() * joy_circle_left_texture_center.x
	# Update the position of the joystick's top texture
	joy_circle_left_texture_rect.global_position = joy_circle_left_texture_position + joystick_left_offset - joy_circle_left_texture_center
	# Normalize the offset for input processing
	joystick_left_offset = joystick_left_offset.normalized() if joystick_left_offset.length() > 0.0 else Vector2.ZERO
	# Handle (left/right) movement input based on joystick offset
	if joystick_left_offset.x > 0.0:
		Input.action_release("move_left")
		Input.action_press("move_right", abs(joystick_left_offset.x))
	elif joystick_left_offset.x < 0.0:
		Input.action_release("move_right")
		Input.action_press("move_left", abs(joystick_left_offset.x))
	else:
		Input.action_release("move_left")
		Input.action_release("move_right")
	# Handle (up/down) movement input based on joystick offset
	if joystick_left_offset.y < 0.0:
		Input.action_release("move_down")
		Input.action_press("move_up", abs(joystick_left_offset.y))
	elif joystick_left_offset.y > 0.0:
		Input.action_release("move_up")
		Input.action_press("move_down", abs(joystick_left_offset.y))
	else:
		Input.action_release("move_up")
		Input.action_release("move_down")


## Helper function to reset left joystick touch input.
func _reset_left_touch() -> void:
	joy_circle_left_texture_rect.global_position = joystick_left.position
	joystick_left_offset = Vector2.ZERO
	Input.action_release("move_up")
	Input.action_release("move_down")
	Input.action_release("move_left")
	Input.action_release("move_right")


## Helper function to handle right joystick touch input.
func _handle_right_touch(pos: Vector2) -> void:
	# Calculate the difference between the touch position and the center of the joystick's inital position
	joystick_right_offset = pos - joy_circle_right_texture_position
	# Check if the offset exceeds the joystick's radius
	if joystick_right_offset.length() > joy_circle_right_texture_center.x:
		# Clamp the offset to the joystick's radius
		joystick_right_offset = joystick_right_offset.normalized() * joy_circle_right_texture_center.x
	# Update the position of the joystick's top texture
	joy_circle_right_texture_rect.global_position = joy_circle_right_texture_position + joystick_right_offset - joy_circle_right_texture_center
	# Normalize the offset for input processing
	joystick_right_offset = joystick_right_offset.normalized() if joystick_right_offset.length() > 0.0 else Vector2.ZERO
	# Handle (left/right) look input based on joystick offset
	if joystick_right_offset.x > 0.0:
		Input.action_release("look_left")
		Input.action_press("look_right", abs(joystick_right_offset.x))
	elif joystick_right_offset.x < 0.0:
		Input.action_release("look_right")
		Input.action_press("look_left", abs(joystick_right_offset.x))
	else:
		Input.action_release("look_left")
		Input.action_release("look_right")
	# Handle (up/down) look input based on joystick offset
	if joystick_right_offset.y < 0.0:
		Input.action_release("look_down")
		Input.action_press("look_up", abs(joystick_right_offset.y))
	elif joystick_right_offset.y > 0.0:
		Input.action_release("look_up")
		Input.action_press("look_down", abs(joystick_right_offset.y))
	else:
		Input.action_release("look_up")
		Input.action_release("look_down")


## Helper function to reset right joystick touch input.
func _reset_right_touch() -> void:
	joy_circle_right_texture_rect.global_position = joystick_right.position
	joystick_right_offset = Vector2.ZERO
	Input.action_release("look_up")
	Input.action_release("look_down")
	Input.action_release("look_left")
	Input.action_release("look_right")
