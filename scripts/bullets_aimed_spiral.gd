extends Node2D

var timer:float = 0
var enemy
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Spawning.create_pool("Yellow-Red", "0", 2000)
	Spawning.create_pool("Green", "0", 2000)
	for a in get_tree().current_scene.get_children():
		if a.is_in_group("enemies"):
			enemy = a
		if a.is_in_group("player"):
			player = a
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(timer <= 0):
		shoot_aimed_spiral()
		shoot_circle()
		timer = 5
	timer -= delta

func shoot_aimed_spiral() -> void:
	var numShots = 45
	var angle
	var initPos = enemy.position
	var playerPos = player.position
	var patternAngle = atan2((playerPos.y - initPos.y), (playerPos.x - initPos.x))
	var angleToPlayer
	
	for i in range(numShots):
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

func shoot_circle() -> void:
	await get_tree().create_timer(0.75).timeout
	for i in 3:
		Spawning.spawn({"position": enemy.position, "rotation": randf_range(0, 2 * PI)}, "Circle")
		await get_tree().create_timer(1.5).timeout
	
