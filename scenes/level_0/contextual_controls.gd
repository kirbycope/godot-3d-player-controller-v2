extends Node

@onready var player: CharacterBody3D = get_parent().get_node("Player")
@onready var item_spring_arm: SpringArm3D = player.camera.item_spring_arm
@onready var ray_cast: RayCast3D = player.camera.ray_cast
@onready var contextual_controls: Label = player.camera.contextual_controls


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Clear the label
	if contextual_controls:
		contextual_controls.text = ""

	# Check if the player is looking at something
	var collider = null
	if ray_cast.is_colliding():
		collider = ray_cast.get_collider()

	# Continue only if there's a collider
	if collider:
		# Show controls for "punching bag"
		if collider.name == "Bag":
			if player.controls.last_input_type == player.controls.InputType.CONTROLLER:
				contextual_controls.text = "Press (L1) to punch left \nPress (R1) to punch right \nPress (L2) to kick left \nPress (R2) to kick right"
			else:
				contextual_controls.text = "Press [MB0] to punch left \nPress [MB1] to punch right \nPress [MB3] to kick left \nPress [MB4] to kick right"

		# Show controls for "picking up objects"
		if item_spring_arm.get_child_count() == 0:
			if collider is RigidBody3D \
			and not collider is VehicleBody3D \
			and not collider.is_in_group("NoPickUp") \
			and player.enable_holding_objects:
				if player.controls.last_input_type == player.controls.InputType.CONTROLLER:
					contextual_controls.text = "Press (X) to pickup"
				else:
					contextual_controls.text = "Press [E] to pickup"

		# Show controls for "climbing ladders"
		if collider.is_in_group("Ladder"):
			if player.is_climbing_ladder:
				if player.controls.last_input_type == player.controls.InputType.CONTROLLER:
					contextual_controls.text = "Press (Y) to release"
				else:
					contextual_controls.text = "Press [Ctrl] to release"
			else:
				if player.controls.last_input_type == player.controls.InputType.CONTROLLER:
					contextual_controls.text = "Press (X) to climb"
				else:
					contextual_controls.text = "Press [E] to climb"

		# Show controls for "driving vehicles"
		if collider is VehicleBody3D \
		and not player.is_driving:
			if player.controls.last_input_type == player.controls.InputType.CONTROLLER:
				contextual_controls.text = "Press (X) to drive"
			else:
				contextual_controls.text = "Press [E] to drive"

	# Show controls for "throwing held objects" or "releasing held objects"
	if item_spring_arm.get_child_count() > 0:
		if player.enable_throwing:
			if player.controls.last_input_type == player.controls.InputType.CONTROLLER:
				contextual_controls.text = "Press (X) to release \nPress (R1) to throw"
			else:
				contextual_controls.text = "Press [E] to release \nPress [MB1] to throw"
		elif player.enable_holding_objects:
			if player.controls.last_input_type == player.controls.InputType.CONTROLLER:
				contextual_controls.text = "Press (X) to release"
			else:
				contextual_controls.text = "Press [E] to release"
