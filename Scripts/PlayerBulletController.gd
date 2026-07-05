extends CharacterBody2D
var pos: Vector2
var dir: float
var rot: float
var player: CharacterBody2D
var startVel: Vector2
@export var bulletSpeed: float
@export var terminalVelocity: float
@export var gravity: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#global_position = pos
	dir = Vector2(1,0).angle_to(get_local_mouse_position())
	global_rotation = rot
	velocity = startVel
	velocity += Vector2(bulletSpeed,0).rotated(dir)
	$Sprite2D.visible = true
	
	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_and_slide()
	#velocity.y= move_toward(velocity.y, terw minalVelocity, gravity * delta / 0.01666666666667)
func _on_timer_timeout() -> void:
	velocity -= startVel
	velocity += player.velocity
	print("corrected velocity")
