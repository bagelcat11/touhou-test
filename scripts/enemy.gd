extends Area2D

@export var MAX_HEALTH = 500
@export var cam:Camera2D
@onready var health = MAX_HEALTH
@onready var bullet_clear_hitbox = $bullet_clear_hitbox

var speed = 0.03

func _ready() -> void:
	GlobalVars.connect("enemy_bullet_clear", _on_enemy_bullet_clear)
	$healthbar.value = health
	$healthbar.max_value = MAX_HEALTH
	$health_label.text = "%d / %d" % [health, MAX_HEALTH]
	GlobalVars.connect("enemy_hit", take_damage)

func take_damage(d):
	if (health <= 0):
		cam.apply_shake()
		get_parent().get_node("enemy/sfx_death").play() # uh oh
		get_parent().get_node("enemy/AnimationPlayer").play("enemy_die")
		GlobalVars.enemy_death.emit()
		await get_tree().create_timer(2.7).timeout
		get_parent().get_node("enemy_mover").queue_free()
		queue_free()
	else:
		health -= d
		$healthbar.value = health
		$health_label.text = "%d / %d" % [health, MAX_HEALTH]

func _physics_process(_delta):
	
	# could be optimized by only updating when getting hit...
	# i did that!!
	#$healthbar.set_value_no_signal(health)
	pass
	
func move_to(next_loc):
	position = lerp(position, next_loc, speed) + (next_loc - position).limit_length(1)
	#print(next_loc)



func _on_enemy_bullet_clear():
	bullet_clear_hitbox.set_collision_mask_value(5, true)
	bullet_clear_hitbox.set_collision_layer_value(2, true)
	for i : int in 100:
		bullet_clear_hitbox.scale = lerp(bullet_clear_hitbox.scale, Vector2(400, 400), 0.01)
		await get_tree().create_timer(0.01).timeout
	bullet_clear_hitbox.scale = Vector2(1, 1)
	bullet_clear_hitbox.set_collision_mask_value(5,false)
	bullet_clear_hitbox.set_collision_layer_value(2,false)
