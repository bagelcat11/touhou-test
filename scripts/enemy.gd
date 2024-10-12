extends Area2D

@export var MAX_HEALTH = 500
@onready var health = MAX_HEALTH

var speed = 0.03

func _ready() -> void:
	$healthbar.value = health
	$healthbar.max_value = MAX_HEALTH
	$health_label.text = "%d / %d" % [health, MAX_HEALTH]
	GlobalVars.connect("enemy_hit", take_damage)

func take_damage(d):
	health -= d
	$healthbar.value = health
	$health_label.text = "%d / %d" % [health, MAX_HEALTH]
	if (health <= 0):
		queue_free()

func _physics_process(_delta):
	
	# could be optimized by only updating when getting hit...
	# i did that!!
	#$healthbar.set_value_no_signal(health)
	pass
	
func move_to(next_loc):
	position = lerp(position, next_loc, speed)
	#print(next_loc)
