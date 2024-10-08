extends Path2D

@export var harv_scene : PackedScene
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	$spawn_timer.start(3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass


func spawn_harvestable():
	var harv_obj = harv_scene.instantiate()
	harv_obj.position = Vector2(100, 100)
	owner.add_child(harv_obj)


func _on_spawn_timer_timeout() -> void:
	spawn_harvestable()
	$spawn_timer.start(rng.randi_range(1, 5))
