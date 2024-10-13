extends Path2D

@export var harv_scene : PackedScene
var rng = RandomNumberGenerator.new()
@onready var spawn_loc = $spawn_location_path

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVars.connect("player_harvest", _player_harvest)
	$spawn_timer.start(3.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass


func spawn_harvestable():
	var harv_obj = harv_scene.instantiate()
	#harv_obj.position = Vector2(100, -50)
	spawn_loc.set_progress_ratio(randf())
	harv_obj.position = spawn_loc.position
	owner.add_child(harv_obj)


func _on_spawn_timer_timeout() -> void:
	spawn_harvestable()
	$spawn_timer.start(3.5)

func _player_harvest() -> void:
	$spawn_timer.start(4.5)
	await get_tree().create_timer(1.0).timeout
	spawn_harvestable()
