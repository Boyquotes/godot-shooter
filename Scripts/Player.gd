extends KinematicBody2D

signal dead
signal damaged

const MAX_HEALTH = 100
const MIN_DAMAGE = 5
const MAX_DAMAGE = 10

var speed = 250
var health = MAX_HEALTH
var velocity = Vector2()
var knockback_vel = Vector2()

func get_input(delta):
	velocity = Vector2()
	if Input.is_action_pressed('right'):
		velocity.x += 1
	if Input.is_action_pressed('left'):
		velocity.x -= 1
	if Input.is_action_pressed('down'):
		velocity.y += 1
	if Input.is_action_pressed('up'):
		velocity.y -= 1
	velocity = velocity.normalized() * speed
	velocity += knockback_vel*100
	knockback_vel *= 0.95

func _physics_process(delta):
	get_input(delta)
	velocity = move_and_slide(velocity)

func _process(_delta):
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("fire"):
		$Gun.fire()
		if !$SoundFire.playing:
			$SoundFire.play()
			$SoundFade.stop()
	elif $SoundFire.playing:
		$SoundFire.stop()
		$SoundFade.play()

func _on_Player_body_entered(body):
	knockback_vel += body.velocity.normalized()
	damage(floor(rand_range(MIN_DAMAGE, MAX_DAMAGE)))

func damage(amount):
	health -= amount
	if health <= 0:
		health = 0
		# Game over
		emit_signal("dead")
	else:
		emit_signal("damaged")
	
	if !$SoundOof.playing:
		$SoundOof.play()
