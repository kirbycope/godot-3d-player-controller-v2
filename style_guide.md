## Formatting
1. Use Tabs instead of spaces for indentation.
	- Each indent level should be one greater than the block containing it.
	- Use 2 indent levels to distinguish continuation lines from regular code blocks.
1. Use a trailing comma on the last line in arrays, dictionaries, and enums.
1. Surround functions and class definitions with two blank lines

## Code Order
https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#code-order
01. @tool, @icon, @static_unload
02. class_name
03. extends
04. ## doc comment

05. signals
06. enums
07. constants
08. static variables
09. @export variables
10. remaining regular variables
11. @onready variables

12. _static_init()
13. remaining static methods
14. overridden built-in virtual methods:
	1. _init()
	2. _enter_tree()
	3. _ready()
	4. _process()
	5. _physics_process()
	6. remaining virtual methods
15. overridden custom methods
16. remaining methods
17. subclasses

## Rules
1. Use implicit types for vars with default values
	- Ex.
	```
	const NODE_NAME := "Crawling"
	```
1. Use explict types for vars without defualt values, or where the default value is the return of some function
	- Ex.
	```
	@onready var player: CharacterBody3D = get_parent()
	```
1. @exports should have ## comments (these are seen in the Editor)
	- Ex.
	```
	@export var foo := "bar" ## The value for that thing, used to determine something
	```
1. There should be two blank lines before a function
1. If a function performs multiple actions, those thoughts should be seperated by a single line
	- By that extention, comments should be at the top of that block. Meaning one comment per "thought"/action
	- Ex.
	```
	func foo(bar: String) -> void:

	```
1. All functions should be explicit about its return value, even if there is none
	- Ex.
	```
	func _input(event) -> void:
	```
1. R.I.P.
	- The .gd functions should appear in the following order
		1. R - _ready()
		1. I - _input()
		1. P - _process()
1. _input() and inputs processed in _process()
	- Player scripts only, do nothing if not authority
		- Ex.
		```
		# Do nothing if not the authority
		if !is_multiplayer_authority(): return
		```
	- Player scripts only, do nothing if the pause menu is visible
		- Ex.
		```
		# Do nothing if the "pause" menu is visible
		if player.pause.visible: return

		```
	- Use `return` to stop input processing when transitioning states
		- Ex.
		```
		transition_state(NODE_STATE, States.State.ROLLING)
		return
		```
1. Functions should be explict about their parameter types
	- Ex.
	```
	func _process(delta: float) -> void:
	```
