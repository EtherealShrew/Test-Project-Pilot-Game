extends PlayerState

var idle_state: PlayerState
var walk_state: PlayerState
var jump_state: PlayerState
var fall_state: PlayerState

func state_init() -> void: #what will run when each state is FIRST created, on instantiation
	print("initiated")
func enter() -> void: #what will run EACH TIME the state is entered
	print("enter ship")
	p.velocity.x = 0 
func exit() -> void: #what will run EACH TIME the state is exited
	print("exit ship")
func state_process_input(event: InputEvent) -> PlayerState:
	return null
func state_process(delta: float) -> PlayerState:
	return null
func state_physics_process(delta: float) -> PlayerState:
	return null
