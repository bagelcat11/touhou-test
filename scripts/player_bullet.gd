extends Area2D

@export var speed = 30
var damage


func _physics_process(_delta):
	position += transform.x * speed # * delta


func _on_area_entered(area: Node2D) -> void:
	if area.is_in_group("enemies"):
		GlobalVars.enemy_hit.emit(5)
		queue_free()
