extends Control

@onready var ani = $AnimationPlayer
@onready var scoreAni = $scoreHandler
var list_of_anims
@onready var bombBar = $bombProg

var current_apples = 0
var displayed_score:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVars.connect("lost_health", update_lives)
	GlobalVars.connect("player_harvest", harvest_var_update)
	list_of_anims = ani.get_animation_list()
	$num_harvested.text = "yea"
	print(GlobalVars.current_num_harvested)
	GlobalVars.score = 0
	$num_bombs.text = "%s x" % GlobalVars.current_num_bombs
	get_tree().paused = false

func harvest_var_update():
	current_apples += 1
	

func update_lives(health_left):
	print(health_left)
	if(health_left == 0):
		$Healthbar.frame = 6
	for anim in list_of_anims:
		if(str(health_left) in anim):
			ani.play(anim)
		

func reset_apples():
	current_apples = 0
	bombBar.value = 0

func update_harvested():
	$num_harvested.text = "%s x" % GlobalVars.current_num_harvested
	
func update_bombs():
	$num_bombs.text = "%s x" % GlobalVars.current_num_bombs
	bombBar.value = lerp(bombBar.value, (current_apples/GlobalVars.apples_per_bomb)*100, 0.15)
	if(current_apples == GlobalVars.apples_per_bomb):
		ani.play("BOMBGAIN")
		
		
		
func update_score():
	if((GlobalVars.score-displayed_score) > 5):
		scoreAni.play("score_flash")
		displayed_score = lerp(displayed_score,int(GlobalVars.score), ease(0.1, 0.4))
	else:
		scoreAni.stop()
		$score.modulate = Color.WHITE
		displayed_score = GlobalVars.score
	$score.text = "\n%d" % displayed_score
	

func _invertColors():
	ani.play("INVERTCOLORS")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#if (Input.is_action_just_pressed("pause")):
		#get_tree().paused = !get_tree().paused
		#$"Pause Screen".visible = !$"Pause Screen".visible
	# could optimize this by picking up signals instead of checking every frame...
	update_harvested()
	update_bombs()
	update_score()



func _on_back_to_menu_button_down() -> void:
	Spawning.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_back_button_down() -> void:
	$"Pause Screen".visible = false
	get_tree().paused = false
