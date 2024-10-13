extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ui_fader.play("game_over_fade")
	var applescore = GlobalVars.current_num_harvested * 5000
	var cardscore = GlobalVars.current_num_bombs * 5000
	var lifescore = GlobalVars.current_lives / 2.0 * 5000
	var totalscore = applescore + cardscore + lifescore
	GlobalVars.score = totalscore
	# guh????
	$game_over_popup/final_score.text = "X %s = %s\n\nX %s = %s\n\nX %s = %s\n---\nTotal: %s" % [GlobalVars.current_num_harvested, applescore, GlobalVars.current_num_bombs, cardscore, GlobalVars.current_lives / 2.0, lifescore, totalscore]
	#get_tree().paused = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_2_menu_pressed() -> void:
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
