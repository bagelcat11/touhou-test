extends Node2D

var timer:float = 0
var enemy
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Spawning.create_pool("Red", "0", 10000)
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
		timer = 5
	timer -= delta

func shoot_aimed_spiral() -> void:
	var angle
	var initPos
	var playerPos
	for i in range(25):
		for j in range(-1, 2):
			angle = lerpf(0, 8 * PI, i / 24.0)
			initPos = enemy.position + (4 * i) * Vector2(cos(angle), sin(angle))
			playerPos = player.position
			Spawning.spawn({ \
				"position": initPos, \
				"rotation": atan2((playerPos.y - initPos.y), (playerPos.x - initPos.x)) + deg_to_rad(30) * j}, \
				"Aim" \
			)
		await get_tree().create_timer(0.1).timeout
			
		
