extends Node2D

var timer : float = 0

var enemy
var player

enum State {START, EASY, MED, HARD, END} 
var curr_state : State = State.START
var prev_state : State = curr_state

@onready var isEnemyAlive : bool = true



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Spawning.create_pool("Yellow-Red", "0", 1000)
	Spawning.create_pool("Orange", "0", 1000)
	Spawning.create_pool("OrangeLarge", "0", 1000)
	Spawning.create_pool("YellowLarge", "0", 500)
	for a in owner.get_children():
		if (isEnemyAlive and a.is_in_group("enemies")):
			enemy = a
		if (a.is_in_group("player")):
			player = a


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(!enemy): 
		isEnemyAlive = false
		queue_free()
		#enemy.get_node("sfx_death").play() # uh oh
	prev_state = curr_state
	
	if(isEnemyAlive and enemy.health > 400 and timer < 30): curr_state = State.EASY
	elif(isEnemyAlive and enemy.health > 250 and timer < 70): curr_state = State.MED
	elif(isEnemyAlive and enemy.health > 0): curr_state = State.HARD
	else: curr_state = State.END
	
	if (isEnemyAlive):
		global_position = enemy.get_global_position()
	
	if(prev_state != curr_state):
		GlobalVars.emit_signal("enemy_bullet_clear")
		enemy.get_node("sfx_phase_change").play() # uh oh
		if(curr_state == State.EASY): start_pattern_easy(400) 
		if(curr_state == State.MED): start_pattern_med(250) 
		if(curr_state == State.HARD): start_pattern_hard(0) 
	
	timer += delta
	


func start_pattern_easy(minHealth : float) -> void:
	while(isEnemyAlive and enemy and curr_state == State.EASY):
		var angle : float = deg_to_rad(randi_range(0, 7) * 45)
		shoot_lanes(angle)
		shoot_lanes(angle + PI)
		enemy.get_node("sfx_fire").play() # uh oh
		await get_tree().create_timer(3).timeout

func start_pattern_med(minHealth : float) -> void:
	while(isEnemyAlive and enemy and curr_state == State.MED):
		shoot_aimed_lanes(minHealth)
		shoot_circle_spin(minHealth, deg_to_rad(80))
		enemy.get_node("sfx_fire").play() # uh oh
		await get_tree().create_timer(randf_range(0, 0.3)).timeout
		shoot_circle_spin(minHealth, deg_to_rad(-80))
		await get_tree().create_timer(5).timeout

func start_pattern_hard(minHealth : float) -> void:
	while(isEnemyAlive and enemy and curr_state == State.HARD):
		shoot_aimed_spiral(minHealth)
		shoot_circle_lanes(minHealth)
		enemy.get_node("sfx_fire").play() # uh oh
		await get_tree().create_timer(6).timeout



func shoot_lanes(angle : float) -> void:
	var deltaX = Vector2(35, 0).rotated(angle)
	var deltaY = Vector2(0, 135).rotated(angle)
	if(!enemy): return
	var initPos = enemy.position - 4 * deltaY
	
	for i in 5:
		for j in 9:
			Spawning.spawn({"position": initPos + i * deltaX + j * deltaY, "rotation": angle}, "OneLarge")

func shoot_aimed_lanes(minHealth : float) -> void:
	if(!enemy): return
	var initPos = enemy.position
	for i : int in 3:
		if(!enemy or enemy.health <= minHealth): return
		var playerPos = player.position
		var angle = atan2((playerPos.y - initPos.y), (playerPos.x - initPos.x))
		for j : int in 8:
			Spawning.spawn({"position": initPos, "rotation": angle + j * deg_to_rad(45)}, "OneLargeYellow")
		await get_tree().create_timer(0.2).timeout

func shoot_circle_spin(minHealth : float, deltaAngle : float) -> void:
	if(!enemy or enemy.health <= minHealth): return
	var initPos : Vector2 = enemy.position
	var radius : Vector2 = Vector2(100, 0)
	var patternAngle : float = randf_range(0, 2 * PI)
	for i : int in 4:
		for j : int in 14:
			var newAngle = patternAngle + j * deg_to_rad(360 / 14)
			Spawning.spawn({
				"position": initPos + radius.rotated(newAngle), 
				"rotation": newAngle + deltaAngle + deg_to_rad(randf_range(-2, 2))}, 
				"One"
			)
		await get_tree().create_timer(0.15).timeout

func shoot_aimed_spiral(minHealth : float) -> void:
	var numShots : int = 45
	var angle : float
	if(!enemy or enemy.health <= minHealth): return
	var initPos : Vector2 = enemy.position
	var playerPos : Vector2 = player.position
	var patternAngle : float = atan2((playerPos.y - initPos.y), (playerPos.x - initPos.x))
	var angleToPlayer : float
	
	for i : int in range(numShots):
		if(!enemy or enemy.health <= minHealth): return
		angle = patternAngle + lerpf(0, 6 * PI, float(i) / (numShots - 1))
		initPos = enemy.position + (120 / numShots * i) * Vector2(cos(angle), sin(angle))
		playerPos = player.position
		angleToPlayer = atan2((playerPos.y - initPos.y), (playerPos.x - initPos.x))
		for j : int in range(-1, 2):
			Spawning.spawn({ \
				"position": initPos, \
				"rotation": angleToPlayer + deg_to_rad(65) * j}, \
				"One" \
			)
		await get_tree().create_timer(1.35 / numShots).timeout

func shoot_circle_lanes(minHealth : float) -> void:
	await get_tree().create_timer(0.75).timeout
	for i : int in 2:
		if(!enemy or enemy.health <= minHealth): return
		Spawning.spawn({"position": enemy.position, "rotation": randf_range(0, 2 * PI)}, "Circle")
		await get_tree().create_timer(2).timeout
