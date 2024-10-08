extends Node2D

# Refrences
@export var bullet: PackedScene = preload("res://scenes/enemy_bullet.tscn")
@export var speed = 1
@export var rot = 0

enum Type { Straight, Spin }

@export var type: Type
var firingRate:float = 0.1

var spawnedBullet
var firingTimer = 0



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	firingTimer += delta
	if(type == Type.Spin):
		rotation += deg_to_rad(1)
	if(firingTimer >= firingRate):
		shoot()
		firingTimer = 0

func shoot():
	if(bullet):
		spawnedBullet = bullet.instantiate()
		spawnedBullet.position = global_position
		if(type == Type.Spin):
			spawnedBullet.rotation = rotation
		spawnedBullet.speed = speed
		spawnedBullet.rot = rot
		owner.add_child(spawnedBullet)
