extends Node

signal enemy_hit(damage)
signal lost_health(damage)
signal player_harvest()
var current_lives
var current_num_harvested

func exit():
	get_tree().quit()
