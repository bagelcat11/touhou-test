extends Control

#@onready var main_game = preload("res://scenes/main_game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$cred_bg.hide()
	$back.hide()
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_start_pressed() -> void:
	$music_fader.play("fade_out_music")
	$sfx_ui.play()
	await get_tree().create_timer(0.5).timeout # lmao
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")


func _on_quit_pressed() -> void:
	$sfx_ui.play()
	GlobalVars.exit()

func _process(delta: float) -> void:
	if(Input.is_key_pressed(KEY_Z)):
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")


func _on_creds_pressed() -> void:
	$sfx_ui.play()
	$cred_bg.show()
	$start.hide()
	$creds.hide()
	$quit.hide()
	$back.show()


func _on_back_pressed() -> void:
	$sfx_ui.play()
	$cred_bg.hide()
	$start.show()
	$creds.show()
	$quit.show()
	$back.hide()



func _on_start_2_button_up() -> void:
	$sfx_ui.play()
	await get_tree().create_timer(0.3).timeout # lmao
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
	pass # Replace with function body.

func _on_music_ui_finished() -> void:
	$music_ui.play()

