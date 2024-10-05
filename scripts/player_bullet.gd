extends Area2D

@export var speed = 30

func _physics_process(_delta):
	position += transform.x * speed # * delta


func _on_area_entered(area: Node2D) -> void:
	if area.is_in_group("enemies"):
		queue_free()
		# damage enemy
