extends Area2D

@onready var sprite = $sprite
@export var speed = 20
@export var rotSpeed = 4
var damage
var color = Color.from_hsv(1, 0.5, 1)


func _physics_process(_delta):
	if(Input.is_key_pressed(KEY_O)):
		speed = 0
		#rotSpeed = 0
	if(Input.is_key_pressed(KEY_P)):
		speed = 20
		#rotSpeed = 4
	position += transform.x * speed # * delta
	color.h += 0.01 
	sprite.modulate = color


func _on_area_entered(area: Node2D) -> void:
	if area.is_in_group("enemies"):
		GlobalVars.enemy_hit.emit(1)
		queue_free()
