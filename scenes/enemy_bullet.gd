extends Area2D

@export var rot = 0
@export var speed = 150

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.x * speed 
	
	if(position.y > get_viewport_rect().size.y or position.x > get_viewport_rect().size.x or position.y < 0 or position.x < 0):
		queue_free()
	
