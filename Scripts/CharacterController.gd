class_name Player
extends CharacterBody2D

#
#@export var walkingSpeed: float #
#@export var airSpeed: float #
#@export var jumpVelocity: float #
#@export var baseGravity: float #
#@export var apexGravity: float #
#@export var fallGravity: float #
#@export var walkingAcceleration: float #
#@export var airAcceleration: float # 
#@export var riseTime: float #
#@export var apexTime: float #
#@export var coyoteTime: float #
#@export var minCoyoteVelocity: float #
#@onready var jump_timer: Timer = $JumpTimer
#@onready var coyote_timer: Timer = $CoyoteTimer
@onready var state_machine = $StateMachine
##@export var coyote_timer_scene: PackedScene
#var currentAirAcceleration: float # 
#var currentGravity: float
##var jumpState: String
##var coyoteTimeGiven: bool
#var isGrounded: bool
#var isJumping: bool
#enum jumpState {GROUNDED, RISING, APEX, DESCENDING, FALLING, COYOTE}
#var currentJumpState: int

func  _ready() -> void:
	state_machine.init(self)
	#coyoteTimeGiven = true

func _unhandled_input(event: InputEvent) -> void:
	state_machine.state_process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.state_physics_process(delta)
	move_and_slide()
	#if is_on_floor():
		#isGrounded = true	
		#
	#if isGrounded == false and not currentJumpState == jumpState.COYOTE:
		#gravity(delta)
		#
	#jump()
		#
	#var direction := Input.get_axis("MoveLeft", "MoveRight")
		#
	#if direction and is_on_floor(): 
		#velocity.x = move_toward(velocity.x, direction * walkingSpeed, walkingAcceleration)
			#
	#elif direction and not is_on_floor():
		#velocity.x = move_toward(velocity.x, direction * walkingSpeed, currentAirAcceleration)
			#
	#elif is_on_floor():
		#velocity.x = move_toward(velocity.x, 0, walkingAcceleration)
			#
	#elif not is_on_floor():
		#velocity.x = move_toward(velocity.x, 0, currentAirAcceleration)
			#
	#else:
		#print("wtf?")

func _process(delta: float) -> void:
	state_machine.state_process(delta)
	#if not is_on_floor():
		#velocity += get_gravity() * delta * currentGravity
		#if coyoteTimeGiven == false:
			#print("do coyote time")
	#else:
		#coyoteTimeGiven = false	
		#currentAirAcceleration = airAcceleration
		#currentGravity = baseGravity
		#$Sprite2D.self_modulate = Color(0.00, 0.00, 0.00)
		##jumpState = "Grounded"	
	#jump()
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta * currentGravity
		#
		#if not jumpState == "Rising" and not jumpState == "Apex" and not jumpState == "Descending":
			#jumpState = "Falling"
			#
			#if coyote_timer.is_stopped() and coyoteTimeGiven == false:
				#jumpState = "Coyote"
				#coyote_timer.start(coyoteTime)
				#print("Coyote time engaged")
				#
	#elif is_on_floor():
		#
		#coyoteTimeGiven = false
		#jumpState = "Grounded"
		#currentAirAcceleration = airAcceleration
		#currentGravity = baseGravity
		#$Sprite2D.self_modulate = Color(0.00, 0.00, 0.00)
		#
	## Handle jump.
	#if Input.is_action_just_pressed("Ascend"):
		#
		#if is_on_floor() or jumpState == "Coyote":
			#
			#velocity.y = jumpVelocity
			#currentGravity = baseGravity
			#currentAirAcceleration = airAcceleration * 0.8
			#jump_timer.start(riseTime)
			#jumpState = "Rising"
			##print("jump started")
			##$Sprite2D.self_modulate = Color(0.675, 0.675, 0.675, 1.0)
			#
	#if Input.is_action_pressed("Crouch") and not is_on_floor() and jumpState == "Falling":
		#currentGravity = fallGravity
		#airAcceleration * 0.25
		#print("Fast Descent")
#

#timer.wait_time=apexTime
#func jump():
	#if isGrounded == true or is_on_floor():
		#currentJumpState = jumpState.GROUNDED
		#isJumping = false
#
	#if currentJumpState == jumpState.GROUNDED:
		#$Sprite2D.self_modulate = Color(0.00, 0.00, 0.00)
		#if not is_on_floor() and velocity.abs().x >= minCoyoteVelocity:
			#coyote_timer.start(coyoteTime)
			#print("coyote started")
			#currentJumpState = jumpState.COYOTE
			#isGrounded = false
			##coyoteTimeGiven = true
		#elif not is_on_floor():
			#currentJumpState = jumpState.FALLING
			#isGrounded = false
				##do coyote time
	#if currentJumpState == jumpState.RISING:
		#currentGravity = baseGravity
		#currentAirAcceleration = airAcceleration * 0.8
		#$Sprite2D.self_modulate = Color(0.933, 0.758, 0.0, 1.0)
		#
	#if currentJumpState == jumpState.COYOTE:
		#currentGravity = baseGravity
		#currentAirAcceleration = walkingAcceleration
		#$Sprite2D.self_modulate = Color(0.0, 0.941, 0.0, 1.0)
		#
	#elif currentJumpState == jumpState.APEX:
		#currentGravity = apexGravity
		#currentAirAcceleration = airAcceleration * 1.5
		#$Sprite2D.self_modulate = Color(0.962, 0.0, 0.0, 1.0)
		#
	#elif currentJumpState == jumpState.DESCENDING:
		#currentGravity = fallGravity
		#currentAirAcceleration = airAcceleration * 0.5
		#$Sprite2D.self_modulate = Color(0.664, 0.515, 0.401, 1.0)
		#
	#elif currentJumpState == jumpState.FALLING:
		#$Sprite2D.self_modulate = Color(0.961, 0.0, 0.641, 1.0)
		#if Input.is_action_pressed("Crouch"):
			#$Sprite2D.self_modulate = Color(0.786, 0.459, 0.0, 1.0)
			#currentGravity = fallGravity
			#airAcceleration * 0.25
			#print("Fast Descent")
		#
	#if Input.is_action_just_pressed("Ascend"):
		#print("try jump")
		#if currentJumpState == jumpState.GROUNDED or currentJumpState == jumpState.COYOTE:
			#currentJumpState = jumpState.RISING 
			#velocity.y = jumpVelocity #adds upwards velocity
			#coyote_timer.stop()
			#jump_timer.start(riseTime) #starts timer chain
			#currentJumpState = jumpState.RISING #changes to RISING state
			#isJumping = true 
			#isGrounded = false 
			#print("jump")
	#
	#
#func _on_jump_timer_timeout() -> void:
	#if currentJumpState == jumpState.RISING:
		#currentJumpState = jumpState.APEX
		#jump_timer.start(apexTime)
		#
	#elif currentJumpState == jumpState.APEX:
		#currentJumpState = jumpState.DESCENDING
#
#func _on_coyote_timer_timeout() -> void:
	#print("coyote over")
	#currentJumpState = jumpState.FALLING
	#
