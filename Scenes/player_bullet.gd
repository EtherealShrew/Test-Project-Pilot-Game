extends Node2D

@export var SPEED: int
var inherited_speed: int
# Called when the node enters the scene tree for the first time.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += transform.x * SPEED 
	
func _ready() -> void:
	print("ready")
