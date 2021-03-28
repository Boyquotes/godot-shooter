extends Node2D

var enemy = preload("res://Scenes/Enemy.tscn")

const SPAWN_RATE = 0.05
const SPAWN_MIN_X = 1024/2 + 40
const SPAWN_MIN_Y = 600/2 + 40
const SPAWN_RANGE = 800
const MAX_ENEMIES = 20

var kill_count = 0

func update_kill_count():
	$GUI/KillCount.text = str(kill_count)

func update_health():
	$GUI/Health.text = str($Player.health)

func _ready():
	randomize()
	update_kill_count()
	update_health()

func _physics_process(delta):
	if $Enemies.get_child_count() >= MAX_ENEMIES:
		return
	
	if rand_range(0, 1) < SPAWN_RATE:
		var enemy_instance = enemy.instance()
		var pos = $Player.position
		var x = rand_range(0, SPAWN_RANGE)
		var y = rand_range(0, SPAWN_RANGE)
		if x < SPAWN_MIN_X && y < SPAWN_MIN_Y:
			# Don't spawn in the player's view
			return
		if rand_range(0, 1) < 0.5:
			x = -x
		if rand_range(0, 1) < 0.5:
			y = -y
		pos += Vector2(x, y)
		enemy_instance.position = pos
		enemy_instance.target = $Player
		enemy_instance.connect("dead", self, "_on_Enemy_dead")
		$Enemies.add_child(enemy_instance)

func _on_Player_dead():
	$Player.visible = false
	$GUI/RestartMenu.visible = true
	get_tree().paused = true
	kill_count = 0
	update_kill_count()
	update_health()

func _on_Restart_pressed():
	$Player.health = $Player.MAX_HEALTH
	$Player.visible = true
	$GUI/RestartMenu.visible = false
	# Restart the game
	$Player.position = Vector2()
	for child in $Enemies.get_children():
		$Enemies.remove_child(child)
	get_tree().paused = false

func _on_Enemy_dead():
	kill_count += 1
	$GUI/KillCount.text = str(kill_count)

func _on_Player_damaged():
	update_health()
