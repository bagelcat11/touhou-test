extends Node2D

@onready var tutorial_done = false
@onready var hasDashedB4 = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disable_enemy()
	disable_harvest()
	GlobalVars.connect("passed_tutorial", enable_enemy)
	GlobalVars.connect("has_moved", tut_move_done)
	$prompt_shoot.hide()
	
func enable_enemy():
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (not hasDashedB4 and Input.is_action_just_pressed("dash")):
		hasDashedB4 = true
		#print("yes!!!!!!!!!")
		tut_dash_done()
