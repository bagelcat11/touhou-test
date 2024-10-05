extends Area2D

@export var speed = 30

func _physics_process(_delta):
	position += transform.x * speed # * delta

func _on_Bullet_body_entered(body):
	# if body is boss, damage boss
	queue_free()	# delete this bullet
