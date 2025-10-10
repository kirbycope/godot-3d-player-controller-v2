extends CanvasLayer


@onready var is_crawling = $States/IsCrawling
@onready var is_crouching = $States/IsCrouching
@onready var is_falling = $States/IsFalling
@onready var is_jumping = $States/IsJumping
@onready var is_on_floor = $States/IsOnFloor
@onready var is_running = $States/IsRunning
@onready var is_sprinting = $States/IsSprinting
@onready var is_standing = $States/IsStanding
@onready var is_walking = $States/IsWalking
@onready var cpu = $Performance/CPU
@onready var gpu = $Performance/GPU
@onready var ram = $Performance/RAM
@onready var fps = $Performance/FPS
@onready var player: CharacterBody3D = get_parent()
@onready var coordinates = $Coordinates
@onready var velocity = $Velocity


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	if visible:
		is_crawling.button_pressed = player.is_crawling
		is_crouching.button_pressed = player.is_crouching
		is_falling.button_pressed = player.is_falling
		is_jumping.button_pressed = player.is_jumping
		is_on_floor.button_pressed = player.is_on_floor()
		is_running.button_pressed = player.is_running
		is_sprinting.button_pressed = player.is_sprinting
		is_standing.button_pressed = player.is_standing
		is_walking.button_pressed = player.is_walking
		coordinates.text = "[center][color=red]X:[/color]%.1f [color=green]Y:[/color]%.1f [color=blue]Z:[/color]%.1f[/center]" % [player.global_position.x, player.global_position.y, player.global_position.z]
		velocity.text = "[center][color=red]X:[/color]%.1f [color=green]Y:[/color]%.1f [color=blue]Z:[/color]%.1f[/center]" % [player.velocity.x, player.velocity.y, player.velocity.z]
		cpu.text = "CPU: %.1f%%" % (Performance.get_monitor(Performance.TIME_PROCESS) * 100.0)
		gpu.text = "GPU: %.1f%%" % (Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 100.0)
		ram.text = "RAM: %.2f MB" % (OS.get_static_memory_usage() / 1024.0 / 1024.0)
		fps.text = "FPS: %d" % Engine.get_frames_per_second()
