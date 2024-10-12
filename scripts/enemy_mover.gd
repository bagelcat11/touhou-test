extends Path2D

var next_location
var e
var rng = RandomNumberGenerator.new()
@onready var moving = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVars.connect("passed_tutorial", start_things)
	
func start_things():
	#next_location = $enemy.position
	$time_to_next_move.start()
	e = get_parent().get_node("enemy") # uh oh
	print("starting")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (moving):
		if (e.position.distance_to($enemy_location.position) > 0.5):
			e.move_to($enemy_location.position)
		else:
			moving = false
			#$time_to_next_move.start()
	elif ($time_to_next_move.is_stopped()):
		$time_to_next_move.start()


func _on_time_to_next_move_timeout() -> void:
	print('heyo')
	while (e.position.distance_to($enemy_location.position) < 40):
		$enemy_location.progress_ratio = randf()
	moving = true
