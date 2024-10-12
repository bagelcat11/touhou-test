extends Node

signal enemy_hit(damage)
signal lost_health(damage)
signal death()
signal player_harvest()
signal enemy_bullet_clear()
signal has_moved()
signal passed_tutorial()
signal first_bomb()
signal has_shot()


var current_lives
var current_num_harvested
var current_num_bombs
var score


var apples_per_bomb:float = 5
var max_bombs:float = 5

func exit():
	get_tree().quit()
