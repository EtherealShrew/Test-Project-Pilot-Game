extends PlayerState

var idle_state: PlayerState
var walk_state: PlayerState
var jump_state: PlayerState
var fall_state: PlayerState

func state_init() -> void:
	print("initiated")
func enter() -> void:
	print("enter walk")
	player.velocity.x = 0
func exit() -> void:
	print("exit walk")
func state_process_input(event: InputEvent) -> PlayerState:
	return null
func state_process(delta: float) -> PlayerState:
	return null
func state_physics_process(delta: float) -> PlayerState:
	return null
