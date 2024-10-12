extends Node2D

var player_dead = false
@onready var UI = $UI
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	GlobalVars.connect("death",die)

func die():
	set_process(true)
	UI._invertColors()
	player_dead = true

func _process(delta: float) -> void:
	if(player_dead and Engine.time_scale > 0.01):
		Engine.time_scale = lerp(Engine.time_scale,0.005, 0.01)
	
	
