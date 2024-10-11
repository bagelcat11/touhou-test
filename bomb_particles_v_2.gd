extends GPUParticles2D

@export var speed = 0.0005
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scale = lerp(scale,Vector2(30,30), speed)
