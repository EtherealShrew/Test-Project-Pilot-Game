extends Node2D
@onready var gun_pivot: Node2D = $GunPivot
@onready var temp_gun_sprite: Sprite2D = $GunPivot/GunLocation/Gun/TempGunSprite
const PLAYER_BULLET = preload("uid://dndcn1v32xqql")
@onready var barrel_tip: Marker2D = $GunPivot/GunLocation/Gun/BarrelTip
var current_tip: Marker2D
@onready var barrel_tip_r: Marker2D = $GunPivot/GunLocation/Gun/BarrelTipR
@onready var barrel_tip_l: Marker2D = $GunPivot/GunLocation/Gun/BarrelTipL


# Called every frame. 'delta' is the elapsed time since the previous frame.
func  _process(delta: float) -> void:
	gun_pivot.look_at(get_global_mouse_position())
	gun_pivot.rotation_degrees = wrap(gun_pivot.rotation_degrees, 0, 360)
	#print(gun_pivot.rotation_degrees)
	if gun_pivot.rotation_degrees > 90 and gun_pivot.rotation_degrees < 270:
		temp_gun_sprite.flip_v = true
		current_tip = barrel_tip_l
	else:
		temp_gun_sprite.flip_v = false
		current_tip = barrel_tip_r
		
	if Input.is_action_just_pressed("Fire"):
		var bullet_instance: Node2D = PLAYER_BULLET.instantiate() 
		get_tree().root.add_child(bullet_instance)
		bullet_instance.global_position = current_tip.global_position
		bullet_instance.rotation = gun_pivot.rotation
	if current_tip == barrel_tip_l:
		print("left")
	elif current_tip == barrel_tip_r:
		print("right")
