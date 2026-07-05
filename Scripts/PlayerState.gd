class_name PlayerState
extends Node

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var p: Player

func state_init() -> void:
	pass
func enter() -> void: #If I run "super()" in any enter function which inhereits from playerstate, it will run all of this scripts "enter()" function. 
	pass
func exit() -> void:
	pass
func state_process_input(event: InputEvent) -> PlayerState: #Where most of the transition conditions will be kept
	return null
func state_process(delta: float) -> PlayerState:# Effectively the same as "_process" it's just called by the ScriptMachine, and not the Engine, so that it can be turned on and off for each state selectively
	return null
func state_physics_process(delta: float) -> PlayerState: # Same as "_physics_process" in the same way "state_process" = "_process"
	return null
