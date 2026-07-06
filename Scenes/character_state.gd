extends PlayerState

var idle_state: PlayerState
var walk_state: PlayerState
var jump_state: PlayerState
var fall_state: PlayerState

@export var walkingSpeed: float 
@export var sprintSpeed: float 
@export var airSpeed: float 
@export var sprintAirSpeed: float 
@export var jumpVelocity: float 
@export var baseGravity: float 
@export var apexGravity: float 
@export var fallGravity: float 
@export var walkingAcceleration: float 
@export var sprintingAcceleration: float 
@export var airAcceleration: float 
@export var riseTime: float 
@export var apexTime: float 
@export var coyoteTime: float 
@export var minCoyoteVelocity: float 
@export var jump_timer: Timer
@export var coyote_timer: Timer 
@export var start_timer: Timer 
@export var state_machine: Node
@export var player_sprite: Sprite2D
@export var wall_slide_right: Area2D
@export var wall_slide_left: Area2D


var currentAirAcceleration: float  
var currentGravity: float
var launchVelocity: float
var isGrounded: bool
var isJumping: bool
var isSprinting: bool
var waitingToJump: bool = false
enum moveState {IDLE, WALK, SPRINT, SLIDE, CROUCH, AIR_STRAFE, AIR_IDLE}
enum jumpState {GROUNDED, RISING, APEX, DESCENDING, FALLING, COYOTE}
var currentJumpState: int
var currentMoveState: int
#since this script extends from PlayerState, it also has the variables "p" for player (the player CharacterBody2D), "gravity", and the "stateList" array.

func state_init() -> void:
	print("initiated")
	
func enter() -> void:
	currentGravity = baseGravity
	isSprinting = false
	isGrounded = true
	currentMoveState = moveState.IDLE
	currentJumpState = jumpState.GROUNDED
	
	coyote_timer.stop()
	print("enter character")
	
func exit() -> void:
	coyote_timer.stop()
	currentMoveState = moveState.IDLE
	currentJumpState = jumpState.GROUNDED
	#p.velocity = new Vector3(0,0,0)
	print("exit character")
	
	
	
func state_process_input(event: InputEvent) -> PlayerState:
	if Input.is_key_pressed(KEY_1):
		return state_machine.ship_state
	else: return null
	
func state_process(delta: float) -> PlayerState:
	return null
	
func state_physics_process(delta: float) -> PlayerState:
	if Input.is_action_just_pressed("Ascend") && isGrounded == false:
		waitingToJump = true
		start_timer.start(0.2)
		print("waiting to jump")
	
	if p.is_on_floor():
		isGrounded = true	
		
	if isGrounded == false and not currentJumpState == jumpState.COYOTE:
		run_gravity(delta)
	
	jump()
	
	var direction := Input.get_axis("MoveLeft", "MoveRight")
	
	if p.is_on_floor():
		walk(direction)
	else:
		air_strafe(direction)	
	return null

func walk(direction):
	if direction:
		if Input.is_action_pressed("Sprint"):
			currentMoveState = moveState.SPRINT
			p.velocity.x = move_toward(p.velocity.x, direction * sprintSpeed, sprintingAcceleration)
			isSprinting = true
			#print("sprint")
		else:
			p.velocity.x = move_toward(p.velocity.x, direction * walkingSpeed, walkingAcceleration)
			currentMoveState = moveState.WALK
			isSprinting = false
			#print("walk")
	else:
		p.velocity.x = move_toward(p.velocity.x, 0, walkingAcceleration)
		currentMoveState = moveState.IDLE
		isSprinting = false
	
func air_strafe(direction):
	if launchVelocity < walkingSpeed:
		launchVelocity = walkingSpeed
	
	if direction:
		if isSprinting == false:
			p.velocity.x = move_toward(p.velocity.x, direction * launchVelocity, currentAirAcceleration)
			currentMoveState = moveState.AIR_STRAFE
		elif isSprinting == true and currentJumpState == jumpState.RISING:
			p.velocity.x = move_toward(p.velocity.x, direction * launchVelocity, currentAirAcceleration)
			currentMoveState = moveState.AIR_STRAFE
		elif isSprinting == true and currentJumpState == jumpState.APEX:
			p.velocity.x = move_toward(p.velocity.x, direction * launchVelocity, currentAirAcceleration)
			currentMoveState = moveState.AIR_STRAFE
		elif isSprinting == true and currentJumpState == jumpState.DESCENDING:
			p.velocity.x = move_toward(p.velocity.x, direction * launchVelocity, currentAirAcceleration)
			currentMoveState = moveState.AIR_STRAFE
	else:
		p.velocity.x = move_toward(p.velocity.x, 0, currentAirAcceleration)
		currentMoveState = moveState.AIR_IDLE
	
func jump():
	if isGrounded == true or p.is_on_floor():
			currentJumpState = jumpState.GROUNDED
			isJumping = false
			
	if currentJumpState == jumpState.GROUNDED:
		player_sprite.self_modulate = Color(0.00, 0.00, 0.00)
		if not p.is_on_floor() and p.velocity.abs().x >= minCoyoteVelocity:
			coyote_timer.start(coyoteTime)
			print("coyote started")
			currentJumpState = jumpState.COYOTE
			isGrounded = false
			#coyoteTimeGiven = true
		elif not p.is_on_floor():
			currentJumpState = jumpState.FALLING
			launchVelocity = p.velocity.abs().x
			isGrounded = false
				#do coyote time
	if currentJumpState == jumpState.RISING:
		currentGravity = baseGravity
		currentAirAcceleration = airAcceleration * 0.8
		player_sprite.self_modulate = Color(0.933, 0.758, 0.0, 1.0)
		
	if currentJumpState == jumpState.COYOTE:
		currentGravity = baseGravity
		currentAirAcceleration = walkingAcceleration
		player_sprite.self_modulate = Color(0.0, 0.941, 0.0, 1.0)
		
	elif currentJumpState == jumpState.APEX:
		currentGravity = apexGravity
		currentAirAcceleration = airAcceleration * 1.5
		player_sprite.self_modulate = Color(0.962, 0.0, 0.0, 1.0)
		
	elif currentJumpState == jumpState.DESCENDING:
		currentGravity = fallGravity
		currentAirAcceleration = airAcceleration * 0.5
		player_sprite.self_modulate = Color(0.664, 0.515, 0.401, 1.0)
		
	elif currentJumpState == jumpState.FALLING:
		player_sprite.self_modulate = Color(0.961, 0.0, 0.641, 1.0)
		if Input.is_action_pressed("Crouch"):
			player_sprite.self_modulate = Color(0.786, 0.459, 0.0, 1.0)
			currentGravity = fallGravity
			airAcceleration * 0.25
			print("Fast Descent")
		
	if Input.is_action_just_pressed("Ascend") or waitingToJump == true:
		print(currentJumpState)
		if currentJumpState == jumpState.GROUNDED or currentJumpState == jumpState.COYOTE:
			currentJumpState = jumpState.RISING 
			p.velocity.y += jumpVelocity #adds upwards velocity
			coyote_timer.stop()
			jump_timer.start(riseTime) #starts timer chain
			currentJumpState = jumpState.RISING #changes to RISING state
			isJumping = true 
			isGrounded = false 
			waitingToJump = false
			launchVelocity = p.velocity.abs().x
			print("jump")

func run_gravity(delta: float):
	p.velocity += p.get_gravity() * delta * currentGravity

func _on_jump_timer_timeout() -> void:
	if currentJumpState == jumpState.RISING:
		currentJumpState = jumpState.APEX
		jump_timer.start(apexTime)
		
	elif currentJumpState == jumpState.APEX:
		currentJumpState = jumpState.DESCENDING
		
func _on_coyote_timer_timeout() -> void:
	print("coyote over")
	currentJumpState = jumpState.FALLING
	
func _on_start_timer_timeout() -> void:
	print("waited too long to jump")
	waitingToJump = false
	
