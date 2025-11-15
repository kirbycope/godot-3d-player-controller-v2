extends BaseState

## Handles mantling state: climbing up from a ledge hang to standing position.

const ANIMATION_MANTLING := "Hanging_Braced_To_Crouch/mixamo_com"
const NODE_NAME := "Mantling"
const NODE_STATE := States.State.MANTLING


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return


## Start "mantling".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.MANTLING

	# Flag the player as "mantling"
	player.is_mantling = true


## Stop "mantling".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "mantling"
	player.is_hanging = false
