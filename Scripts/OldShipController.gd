extends RigidBody2D

@export var thrusterStrength: float
@export var lockedStrength: float
@export var rcsStrength: float
@export var maxSpeed: float
var moveInput: Vector2
var test: bool
var altitudeLock: bool

func _ready():
	can_sleep = false #Rigidbody2D nodes can "sleep" when not interacted with, which disables physics interactions. This keeps the player always awake, at the price of a tiny hit to performance
	add_constant_central_force(get_gravity() * 10)
	
func _process(delta: float) -> void:
	detectMoveInput()
	
func detectMoveInput():
	# Detects player input up, down, left, and right, and creates a Vector2D called "moveInput," 
	# where the .x and .y values correspond to the movement input on each axis
	if Input.is_action_pressed("Ascend"):
		moveInput.y = -1
	elif Input.is_action_pressed("Descend"):
		moveInput.y = 1
	else:
		moveInput.y = 0
	if Input.is_action_pressed("MoveLeft"):
		moveInput.x = -1
	elif Input.is_action_pressed("MoveRight"):
		moveInput.x = 1
	else:
		moveInput.x = 0
	
	# VVV Detects altitude lock has just been activated or deactivated; 
	# Enabled and Disabled on each press of key "CAPSLOCK" or letter "O"
	if Input.is_action_just_pressed("TEST") and altitudeLock == false:
		altitudeLock = true	
	elif Input.is_action_just_pressed("TEST") and altitudeLock == true:
		altitudeLock = false
		
	#print(altitudeLock)
	
func _physics_process(delta: float) -> void:
	if altitudeLock == true:
		apply_central_force(get_gravity() * -10)
		apply_central_force(Vector2(moveInput.x * lockedStrength * delta, moveInput.y * lockedStrength * delta))
		$Sprite2D.self_modulate = Color(0.00, 0.00, 0.00)
	else:
		apply_central_force(Vector2(moveInput.x * thrusterStrength * delta, moveInput.y * thrusterStrength * delta))
		$Sprite2D.self_modulate = Color(1.00, 1.00, 1.00)
		
	print(linear_velocity.y)
		
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity = state.linear_velocity.limit_length(maxSpeed)
	
# TOOLS AND SCRIPTS IM SAVING:
#|	#$Sprite2D.self_modulate = Color(1.00, 1.00, 1.00)
#|  #$Sprite2D.self_modulate = Color(0.00, 0.00, 0.00)
#|  #func _input(event: InputEvent):
#|
#|	#state.linear_velocity.x = moveInput.x * thrusterStrength
#|	#state.linear_velocity.y = moveInput.y * thrusterStrength
