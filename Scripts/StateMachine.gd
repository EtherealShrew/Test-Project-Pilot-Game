extends Node

@export var starting_state: PlayerState
var current_state: PlayerState

@export var character_state: PlayerState
@export var ship_state: PlayerState

func init(parent: Player) -> void:
	for child in get_children(): # runs over every child of StateMachine (itself) and sets their "parent" variable to the "parent" variable passed on by the player when init is run. "parent" is equal to the Character2d that the player is built around
		child.p = parent
		child.state_init()

	change_state(starting_state)
	
# Changes to new state, first calls the exit logic on the current state
func change_state(new_state: PlayerState) -> void:
	if current_state: #checks to ensure there IS a current state
		current_state.exit()
	current_state = new_state
	current_state.enter()

# Calls these functions in the active state. Each function returns a new_state of type PlayerState or "Null" if it doesn't need to change
func state_process_input(event: InputEvent) -> void: # Where most of the transition conditions will be kept. Code-wise, it's identical to "process," but it runs first to change out of states as quickly as possible, before more code is run.
	var new_state = current_state.state_process_input(event)
	if new_state:
		change_state(new_state)
		
func state_process(delta: float) -> void: # Effectively the same as "_process" it's just called by the ScriptMachine, and not the Engine, so that it can be turned on and off for each state selectively
	var new_state = current_state.state_process(delta)
	if new_state:
		change_state(new_state)
		
func state_physics_process(delta: float) -> void: # Same as "_physics_process" in the same way "state_process" = "_process"
	var new_state = current_state.state_physics_process(delta)
	if new_state:
		change_state(new_state)
