extends GPUParticles2D


#this specific angle is the angle to go up and diagonally right on a the default godot window size
#probably should make this dynamic....
@export var angle:float = -29.358
@export var speed:float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation = deg_to_rad(angle)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.x*speed
