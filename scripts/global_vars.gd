extends Node

signal enemy_hit(damage)
signal lost_health(damage)
signal player_harvest()
var current_lives
var current_num_harvested
signal has_moved()
signal passed_tutorial()

func exit():
	get_tree().quit()
