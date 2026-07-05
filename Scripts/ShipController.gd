extends CharacterBody2D

@onready var firing_point: Node2D = $FiringPoint

@export var maxHorzVelocity: float
@export var lockedAcceleration: float
@export var recoilStrength: float
@export var bullet_scene: PackedScene
var acceleration: float
var maxDescentVelocity: float
var terminalVelocity: float
var maxAscentVelocity: float
var vertSpeedDecay: float
var horzSpeedDecay: float
var gravity: float
var moveInput: Vector2
var test: bool
var altitudeLock: bool
var mousePos: Vector2

func  _ready() -> void:
	acceleration = maxHorzVelocity / 25
	horzSpeedDecay = acceleration * 0.15
	vertSpeedDecay = acceleration / 2
	maxDescentVelocity = maxHorzVelocity * 1.8
	maxAscentVelocity = maxHorzVelocity #* 0.88
	terminalVelocity = maxHorzVelocity * 1.5
	gravity = acceleration * 0.8 #0.85w

func _physics_process(delta: float) -> void:
	if altitudeLock == false: 
		if  moveInput.y < 0: # i.e. intending to move upwards
			velocity.y = move_toward(velocity.y, maxAscentVelocity * moveInput.y, acceleration * delta / 0.01666666666667)
		elif moveInput.y > 0: # i.e. intending to move downwards
			velocity.y = move_toward(velocity.y, maxDescentVelocity * moveInput.y, acceleration * delta / 0.01666666666667)
		else:
			velocity.y = move_toward(velocity.y, terminalVelocity, gravity * delta / 0.01666666666667)
		if  moveInput.x: # i.e. intending to left OR right
			velocity.x = move_toward(velocity.x, maxHorzVelocity * moveInput.x, acceleration * delta / 0.01666666666667)
		else:
			velocity.x = move_toward(velocity.x, 0, horzSpeedDecay * delta / 0.01666666666667)
		$Sprite2D.self_modulate = Color(1.00, 1.00, 1.00)
	else:
		if  moveInput.y < 0: # i.e. intending to move upwards
			velocity.y = move_toward(velocity.y, maxAscentVelocity * moveInput.y, lockedAcceleration * delta / 0.01666666666667)
		elif moveInput.y > 0: # i.e. intending to move downwards
			velocity.y = move_toward(velocity.y, maxDescentVelocity * moveInput.y, lockedAcceleration * delta / 0.01666666666667)
		else:
			velocity.y = move_toward(velocity.y, 0, lockedAcceleration * delta / 0.01666666666667)	
		if  moveInput.x: # i.e. intending to left OR right
			velocity.x = move_toward(velocity.x, maxHorzVelocity * moveInput.x, acceleration * delta / 0.01666666666667)
		else:
			velocity.x = move_toward(velocity.x, 0, horzSpeedDecay * 2 * delta / 0.01666666666667)
		$Sprite2D.self_modulate = Color(0.00, 0.00, 0.00)
	move_and_slide() # moves the body according to velocity, while respecting collisions, slopes, and other factors
	queue_redraw()
	if Input.is_action_just_pressed("Fire"):
		handleFiring()
	#if not is_on_floor():
		#velocity += get_gravity() * delta

func _process(delta: float) -> void:
	detectInput()
	
	#print(mousePos)
	#var mousePos = global_position.direction_to(get_global_mouse_position())	
	
func detectInput():
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
		
func handleFiring():
	var new_bullet = bullet_scene.instantiate()
	new_bullet.add_to_group("Projectiles", false)
	new_bullet.global_position = firing_point.global_position
	new_bullet.startVel = velocity
	new_bullet.dir = Vector2(1,0).angle_to(get_local_mouse_position())
	new_bullet.rot = global_rotation
	new_bullet.player = $"."
	get_parent().add_child(new_bullet)
	velocity -= Vector2(recoilStrength,0).rotated(Vector2(1,0).angle_to(get_local_mouse_position()))
	print(new_bullet.dir)

func _draw() -> void:
	#draw_line(global_position, mousePos, Color(0,1,0), 100.0, false)
	mousePos = get_local_mouse_position()
	draw_line(Vector2.ZERO, mousePos, Color.DARK_RED, 100, false)
	
 
