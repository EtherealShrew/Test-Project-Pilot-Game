extends CharacterBody2D


@export var walkingSpeed: float 
@export var sprintSpeed: float 
@export var airSpeed: float 
@export var sprintAirSpeed: float 
@export var jumpVelocity: float 
@export var baseGravity: float 
@export var apexGravity: float 
@export var fallGravity: float 
@export var wall_slide_gravity: float 
@export var wall_slide_terminal_velocity: float 
@export var current_terminal_velocity: float 
@export var base_terminal_velocity: float 
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
@export var wall_slide_timer: Timer 
@export var state_machine: Node
@export var player_sprite: Sprite2D
@export var wall_slide_right: Area2D
@export var wall_slide_left: Area2D
@export var wall_slide_time: float
@onready var state_chart: StateChart = get_node("StateChart")

var left_touched_walls: Array[Node2D]
var right_touched_walls: Array[Node2D]
var x_direction: float
var currentAirAcceleration: float  
var currentGravity: float
var launchVelocity: float
var isGrounded: bool
var isJumping: bool
var isSprinting: bool
var waitingToJump: bool = false
enum moveState {IDLE, WALK, SPRINT, SLIDE, CROUCH, AIR_STRAFE, AIR_IDLE}
enum jumpState {GROUNDED, RISING, APEX, DESCENDING, FALLING, COYOTE}
enum slide_side {LEFT, RIGHT, NONE}
var slideControl: Dictionary = { "LeftCollision": false, "RightCollision": false, "WallCollision": false, "CurrentSlideDirection": 0 }
var currentJumpState: int
var currentMoveState: int


func _ready() -> void:
	#baseGravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	pass
	
	
func _process(delta: float) -> void: # Executed every single frame, better for inputs
	x_direction = Input.get_axis("MoveLeft", "MoveRight")
	if left_touched_walls.is_empty() == true and right_touched_walls.is_empty() == true:
		wall_slide_timer.stop()
	
	
func _physics_process(delta: float) -> void: # Executed at a fixed rate of 60 frames per second
	move_and_slide()
	# use "run_gravity(delta)" when a state requires gravity to be applied, and edit current gravity to effect it's strength


func run_gravity(delta: float) -> void:
	velocity.y += get_gravity().y * delta * currentGravity
	if velocity.abs().y >+ current_terminal_velocity:
		velocity.y = move_toward(velocity.y, current_terminal_velocity, velocity.abs().y)
		
	print(velocity.abs().y)
	

func _on_grounded_state_entered() -> void:
	pass

func _on_standing_state_entered() -> void:
	velocity.y = 0
	currentGravity = 0
	player_sprite.self_modulate = Color(0.0, 0.0, 0.0, 1.0)
	currentGravity = 0
	print("standing")


func _on_standing_state_input(event: InputEvent) -> void:
	if Input.is_action_pressed("Crouch"):
		if Input.is_action_pressed("Sprint"):
			#state_chart.send_event("start_sliding")
			print("sliding WOULD start here")
		else: 
			#state_chart.send_event("start_crouching")
			print("crouching WOULD start here")
	if Input.is_action_pressed("Ascend"):
		state_chart.send_event("start_jumping")
		


func _on_standing_state_physics_processing(delta: float) -> void:
	if x_direction:
		if Input.is_action_pressed("Sprint"):
			currentMoveState = moveState.SPRINT
			velocity.x = move_toward(velocity.x, x_direction * sprintSpeed, sprintingAcceleration)
			isSprinting = true
			#print("sprint")
		else:
			velocity.x = move_toward(velocity.x, x_direction * walkingSpeed, walkingAcceleration)
			currentMoveState = moveState.WALK
			isSprinting = false
			#print("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, walkingAcceleration)
		currentMoveState = moveState.IDLE
		isSprinting = false
	if is_on_floor() != true:
		state_chart.send_event("start_coyote")
	#run_gravity(delta)


func _on_standing_state_exited() -> void:
	isSprinting = false


##
##
##			Seperation between Airborned and Grounded states
##
##


func _on_airborne_state_physics_processing(delta: float) -> void:
	pass


func _on_coyote_state_entered() -> void:
	player_sprite.self_modulate = Color(0.0, 0.663, 0.236, 1.0)
	currentGravity = 0
	coyote_timer.start(coyoteTime)
	print("coyote")
	
func _on_coyote_timer_timeout() -> void:
	state_chart.send_event("start_falling")


func _on_coyote_state_input(event: InputEvent) -> void:
	if Input.is_action_pressed("Crouch"):
		state_chart.send_event("start_falling")
	if Input.is_action_just_pressed("Ascend"):
		state_chart.send_event("start_jumping")
		print("coyoted")
	
		
func _on_coyote_state_exited() -> void:
	coyote_timer.stop()

func _on_falling_state_entered() -> void:
	currentGravity = baseGravity
	player_sprite.self_modulate = Color(0.961, 0.0, 0.641, 1.0)
	print("falling")
	current_terminal_velocity = base_terminal_velocity
	
	
func _on_falling_state_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Crouch"):
		currentGravity = fallGravity
	else:
		currentGravity = baseGravity
		
	# WILL transition to wall sliding and mantling in the future


func _on_falling_state_physics_processing(delta: float) -> void:
	if x_direction:
			velocity.x = move_toward(velocity.x, x_direction * airSpeed, airAcceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, airAcceleration)
		
	if is_on_floor():
		state_chart.send_event("start_standing")
	if slideControl.get("WallCollision") == true:
		if slideControl.get("RightCollision") == true && x_direction == 1 && wall_slide_timer.is_stopped() == true:
			state_chart.send_event("start_wall_sliding")
		if slideControl.get("LeftCollision") == true && x_direction == -1 && wall_slide_timer.is_stopped() == true:
			state_chart.send_event("start_wall_sliding")
			
	run_gravity(delta)

func _on_jumping_state_physics_processing(delta: float) -> void:
	velocity.x = move_toward(velocity.x, x_direction * airSpeed*1.1 * clamp(launchVelocity / walkingSpeed, 0.8, 2), currentAirAcceleration)
	current_terminal_velocity = base_terminal_velocity
	print(launchVelocity)
	if is_on_floor():
		state_chart.send_event("start_standing")
	if slideControl.get("WallCollision") == true:
		if slideControl.get("RightCollision") == true && x_direction == 1 && wall_slide_timer.is_stopped() == true:
			state_chart.send_event("start_wall_sliding")
		if slideControl.get("LeftCollision") == true && x_direction == -1 && wall_slide_timer.is_stopped() == true:
			state_chart.send_event("start_wall_sliding")
	
	run_gravity(delta)
		

func _on_jump_timer_timeout() -> void:
	state_chart.send_event("progress_jump")


func _on_rising_state_entered() -> void:
	velocity.y += jumpVelocity
	launchVelocity = velocity.abs().x
	if launchVelocity < 1:
		launchVelocity = 1

	currentGravity = baseGravity
	player_sprite.self_modulate = Color(0.933, 0.758, 0.0, 1.0)
	jump_timer.start(riseTime)
	currentAirAcceleration = airAcceleration * 0.8


func _on_rising_state_physics_processing(delta: float) -> void:
	pass

func _on_apex_state_entered() -> void:
	currentGravity = apexGravity
	player_sprite.self_modulate = Color(0.962, 0.0, 0.0, 1.0)
	jump_timer.start(apexTime)
	currentAirAcceleration = airAcceleration * 1.5


func _on_apex_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_descending_state_entered() -> void:
	currentGravity = fallGravity
	jump_timer.start(riseTime)
	player_sprite.self_modulate = Color(0.664, 0.515, 0.401, 1.0)
	currentAirAcceleration = airAcceleration * 0.5


func _on_descending_state_physics_processing(delta: float) -> void:
	pass
	


func _on_wall_sliding_state_entered() -> void:
	current_terminal_velocity = wall_slide_terminal_velocity
	if slideControl.get("RightCollision") == true:
		slideControl.set("CurrentSlideDirection", "Right")
		print("sliding right at " + slideControl.get("CurrentSlideDirection"))
	elif slideControl.get("LeftCollision") == true:
		slideControl.set("CurrentSlideDirection", "Left")
		print("sliding left at " + slideControl.get("CurrentSlideDirection"))
	else:
		slideControl.set("WallCollision", false)
		print("neither works")
	currentGravity = wall_slide_gravity
	player_sprite.self_modulate = Color(1.0, 1.0, 1.0, 1.0)


func _on_wall_sliding_state_input(event: InputEvent) -> void:
	pass

func _on_wall_sliding_state_physics_processing(delta: float) -> void:
	if slideControl.get("CurrentSlideDirection") == "Right":
		velocity.x = 200
		
		if slideControl.get("RightCollision") != true or Input.is_action_pressed("MoveRight") != true:
			slideControl.set("RightCollision", false)
			state_chart.send_event("start_falling")
			
	if slideControl.get("CurrentSlideDirection") == "Left":
		velocity.x = -200
				
		if slideControl.get("LeftCollision") != true or Input.is_action_pressed("MoveLeft") != true:
			slideControl.set("LeftCollision", false)
			state_chart.send_event("start_falling")
			
	if is_on_floor() == true:
		print("landed after wallslide")
		state_chart.send_event("start_standing")
	run_gravity(delta)
	if Input.is_action_pressed("Ascend"):
		velocity.y = 0
		wall_slide_timer.start(wall_slide_time)
		if slideControl.get("CurrentSlideDirection") == "Right":
			velocity.x = jumpVelocity/2
			print("jump right")
			#print(velocity.x)
		if slideControl.get("CurrentSlideDirection") == "Left":
			velocity.x = jumpVelocity * -0.5
			print("jump left")
			#print(velocity.x)
			#velocity.y = 0
		state_chart.send_event("start_jumping")


func _on_wall_sliding_state_exited() -> void:
	pass 

func _on_wall_slide_r_body_entered(body: Node2D) -> void:
	slideControl.set("RightCollision", true)
	slideControl.set("WallCollision", true)
	right_touched_walls.append(body)
	print("right enter")
	print(right_touched_walls)

func _on_wall_slide_r_body_exited(body: Node2D) -> void:
	right_touched_walls.erase(body)
	print(right_touched_walls)
	if right_touched_walls.is_empty() == true:
		slideControl.set("RightCollision", false)
		if slideControl.get("LeftCollision") == false:
			slideControl.set("WallCollision", false)
		print("right exit")


func _on_wall_slide_l_body_entered(body: Node2D) -> void:
	slideControl.set("LeftCollision", true)
	slideControl.set("WallCollision", true)
	left_touched_walls.append(body)
	print("left enter")
	print(right_touched_walls)


func _on_wall_slide_l_body_exited(body: Node2D) -> void:
	left_touched_walls.erase(body)
	if left_touched_walls.is_empty() == true:
		slideControl.set("LeftCollision", false)
		if slideControl.get("RightCollision") == false:
			slideControl.set("WallCollision", false)
		print("left exit")
