extends KinematicBody2D

signal dead

const MAX_HEALTH = 50
const DESIRED_SEPARATION = 70
const MIN_DAMAGE = 5
const MAX_DAMAGE = 15
const SPEED_VARY = 20

var health = MAX_HEALTH
var max_speed = 100
var max_force = 20
var velocity = Vector2()
var knockback_vel = Vector2()

var target: Node2D

func _ready():
	max_speed += rand_range(-SPEED_VARY, SPEED_VARY)

func _process(_delta):
	look_at(target.position)

func _physics_process(delta):
	var separate = separate(get_parent().get_children())
	var seek = seek(target.position)
	velocity += separate*2.0 + seek*1.0
	velocity = velocity.clamped(max_speed)
	velocity += knockback_vel*60
	velocity = move_and_slide(velocity)
	knockback_vel -= 10.0 * delta * knockback_vel

func seek(target: Vector2) -> Vector2:
	var desired = (target - position).normalized() * max_speed
	return (desired - velocity).clamped(max_force)

func separate(from: Array) -> Vector2:
	var sum = Vector2()
	var count = 0
	for child in from:
		if child == self:
			continue
		
		var d = position.distance_to(child.position)
		if d > 0 && d < DESIRED_SEPARATION:
			var diff = (position - child.position).normalized()
			diff /= d
			sum += diff
			count += 1
	
	if count > 0:
		sum /= count
		sum = sum.normalized() * max_speed
		return (sum - velocity).clamped(max_force)
	
	return Vector2()

func _on_Enemy_body_entered(body):
	body.queue_free()
	knockback_vel += body.linear_velocity.normalized();
	damage(rand_range(MIN_DAMAGE, MAX_DAMAGE))

func damage(amount):
	play_zombie_sound()
	splash_blood()
	health -= amount
	if health <= 0:
		emit_signal("dead")
		queue_free()

func play_zombie_sound():
	var x = rand_range(0, 1)
	if $SoundZombie1.playing || $SoundZombie2.playing || $SoundZombie3.playing:
		return
	if x < 0.33:
		$SoundZombie1.play()
	elif x < 0.66:
		$SoundZombie2.play()
	else:
		$SoundZombie3.play()

func splash_blood():
	if !$Blood.emitting:
		$Blood.restart()
