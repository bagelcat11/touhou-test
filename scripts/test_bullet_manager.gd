extends Node2D

var timer:float = 0
var enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for a in get_tree().current_scene.get_children():
		if a.is_in_group("enemies"):
			enemy = a
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(timer > 2):
		Spawning.spawn({"position": enemy.position, "rotation": 0}, "Test")
		timer = 0
	timer += delta
