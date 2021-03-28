extends Node2D

var bullet = preload("res://Scenes/Bullet.tscn")
var bullet_speed = 2000
var spread = 5*PI/180 # 5 degrees

var last_fire = 0
var delay = 100 # miliseconds

func fire():
	var ticks = OS.get_ticks_msec()
	if ticks - last_fire < delay:
		return
	last_fire = ticks
	
	var bullet_instance = bullet.instance();
	bullet_instance.position = $Fire.get_global_transform().get_origin()
	var rot = get_global_transform().get_rotation()
	rot += rand_range(-spread, spread)
	bullet_instance.rotation = rot
	bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rot))
	get_tree().get_root().call_deferred("add_child", bullet_instance)
