extends Node2D

@onready var tutorial_done = false
@onready var hasDashedB4 = false
@export var cam: Camera2D
var player_dead = false
@onready var UI = $UI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVars.connect("death",die)
	disable_enemy()
	disable_harvest()
	GlobalVars.connect("passed_tutorial", enable_enemy)
	GlobalVars.connect("has_moved", tut_move_done)
	GlobalVars.connect("first_bomb", bomb_prompt)
	GlobalVars.connect("bomb_tut_done", bomb_tut_done)
	$prompt_shoot.hide()
	$prompt_bomb.hide()



func die():
	UI._invertColors()
	cam.apply_shake()
	player_dead = true
	

func enable_enemy():
	$sfx_enemy_spawn.play()
	$TilemapTest/enemy.show()
	$TilemapTest/enemy_mover.process_mode = Node.PROCESS_MODE_INHERIT
	$TilemapTest/enemy.process_mode = Node.PROCESS_MODE_INHERIT
	$TilemapTest/EnemyBulletManager.process_mode = Node.PROCESS_MODE_INHERIT
	$prompt_harvest.hide()
	$prompt_shoot.show()
	$ui_fader.play_backwards("fade_out_shoot")
	
func disable_enemy():
	$TilemapTest/enemy.hide()
	$TilemapTest/enemy_mover.process_mode = Node.PROCESS_MODE_DISABLED
	$TilemapTest/enemy.process_mode = Node.PROCESS_MODE_DISABLED
	$TilemapTest/EnemyBulletManager.process_mode = Node.PROCESS_MODE_DISABLED
	
func enable_harvest():
	$TilemapTest/harvestable_spawner.process_mode = Node.PROCESS_MODE_INHERIT
	
func disable_harvest():
	$TilemapTest/harvestable_spawner.process_mode = Node.PROCESS_MODE_DISABLED
	
func tut_move_done():
	$ui_fader.play("fade_out_move")
	
func tut_dash_done():
	$ui_fader2_since_i_cant_play_2_anims_at_once.play("fade_out_dash")
	enable_harvest()
	
func bomb_prompt():
	$ui_fader.play("fade_out_shoot")
	$prompt_bomb.show()
	$ui_fader2_since_i_cant_play_2_anims_at_once.play_backwards("fade_out_bomb")
	$prompt_bomb/bomb_hide_timer.start(10)
	
func bomb_tut_done():
	$ui_fader2_since_i_cant_play_2_anims_at_once.play("fade_out_bomb")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (not hasDashedB4 and Input.is_action_just_pressed("dash")):
		hasDashedB4 = true
		#print("yes!!!!!!!!!")
		tut_dash_done()
	if(player_dead and Engine.time_scale > 0.01):
		Engine.time_scale = lerp(Engine.time_scale, 0.005, ease(delta * 1.75, 0.4))


func _on_bomb_hide_timer_timeout() -> void:
	$prompt_bomb.hide()
