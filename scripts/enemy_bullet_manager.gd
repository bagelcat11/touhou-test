extends Node2D

var timer:float = 0

var enemy
var player

enum State {INIT, EASY, MED, HARD} 
var curr_state = State.INIT
var prev_state = curr_state

@onready var isEnemyAlive = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Spawning.create_pool("Yellow-Red", "0", 1000)
	Spawning.create_pool("Orange", "0", 1000)
	Spawning.create_pool("OrangeLarge", "0", 1000)
	for a in owner.get_children():
		#print(a)
		if (isEnemyAlive and a.is_in_group("enemies")):
			enemy = a
		if (a.is_in_group("player")):
			player = a
	
	# Start shot pattern
	#start_pattern_hard(400)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(!enemy): 
		isEnemyAlive = false
		queue_free()
	prev_state = curr_state
	
	if(isEnemyAlive and enemy.health > 400 and timer < 35): curr_state = State.EASY
	elif(isEnemyAlive and enemy.health > 200 and timer < 70): curr_state = State.MED
	else: curr_state = State.HARD
	
	if (isEnemyAlive):
		global_position = enemy.get_global_position()
	
	if(prev_state != curr_state):
		if(curr_state == State.EASY): start_pattern_easy(400) 
		if(curr_state == State.MED): start_pattern_med(250) 
		if(curr_state == State.HARD): start_pattern_hard(0) 
	
	timer += delta
	


func start_pattern_easy(minHealth : float) -> void:
	await get_tree().create_timer(1.5).timeout
	while(isEnemyAlive and enemy and curr_state == State.EASY):
		var angle:float = deg_to_rad(randi_range(0, 7) * 45)
		shoot_lanes(angle)
		shoot_lanes(angle + PI)
		await get_tree().create_timer(3).timeout

func start_pattern_med(minHealth : float) -> void:
	pass

func start_pattern_hard(minHealth : float) -> void:
	await get_tree().create_timer(1.5).timeout
	while(isEnemyAlive and enemy and curr_state == State.HARD):
		shoot_aimed_spiral(minHealth)
		shoot_circle(minHealth)
		await get_tree().create_timer(6).timeout



func shoot_lanes(angle : float) -> void:
	var deltaX = Vector2(35, 0).rotated(angle)
	var deltaY = Vector2(0, 135).rotated(angle)
	var initPos = enemy.position - 4 * deltaY
	
	for i in 5:
		for j in 9:
			Spawning.spawn({"position": initPos + i * deltaX + j * deltaY, "rotation": angle}, "OneLarge")

func shoot_aimed_spiral(minHealth : float) -> void:
	var numShots = 45
	var angle
	if(!enemy or enemy.health <= minHealth): return
	var initPos = enemy.position
	var playerPos = player.position
	var patternAngle = atan2((playerPos.y - initPos.y), (playerPos.x - initPos.x))
	var angleToPlayer
	
	for i in range(numShots):
		if(!enemy or enemy.health <= minHealth): return
		angle = patternAngle + lerpf(0, 6 * PI, float(i) / (numShots - 1))
		initPos = enemy.position + (120 / numShots * i) * Vector2(cos(angle), sin(angle))
		playerPos = player.position
		angleToPlayer = atan2((playerPos.y - initPos.y), (playerPos.x - initPos.x))
		for j in range(-1, 2):
			Spawning.spawn({ \
				"position": initPos, \
				"rotation": angleToPlayer + deg_to_rad(65) * j}, \
				"One" \
			)
		await get_tree().create_timer(1.35 / numShots).timeout

func shoot_circle(minHealth : float) -> void:
	await get_tree().create_timer(0.75).timeout
	for i in 2:
		if(!enemy or enemy.health <= minHealth): return
		Spawning.spawn({"position": enemy.position, "rotation": randf_range(0, 2 * PI)}, "Circle")
		await get_tree().create_timer(2).timeout
	
