extends Area2D

@export var MAX_HEALTH = 500
@onready var health = MAX_HEALTH

@export var bulletSpawner:PackedScene = preload("res://scenes/bullet_spawner.tscn")
var spawnedBulletSpawner

func _ready() -> void:
	$healthbar.value = health
	$healthbar.max_value = MAX_HEALTH
	$health_label.text = "%d / %d" % [health, MAX_HEALTH]
	GlobalVars.connect("enemy_hit", take_damage)

func take_damage(d):
	health -= d
	$healthbar.value = health
	$health_label.text = "%d / %d" % [health, MAX_HEALTH]
	if (health <= 0):
		queue_free()

func _physics_process(_delta):
	# could be optimized by only updating when getting hit...
	#$healthbar.set_value_no_signal(health)
	pass
