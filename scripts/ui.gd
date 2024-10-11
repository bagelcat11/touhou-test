extends Control

@onready var ani = $AnimationPlayer
var list_of_anims
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVars.connect("lost_health", update_lives)
	list_of_anims = ani.get_animation_list()


func update_lives(health_left):
	print(health_left)
	if(health_left == 0):
		$Healthbar.frame = 6
	for anim in list_of_anims:
		if(str(health_left) in anim):
			ani.play(anim)
		

func update_harvested():
	$num_harvested.text = "Items harvested: %s" % GlobalVars.current_num_harvested


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	update_harvested()
