extends Node2D

@onready var tutorial_done = false
@onready var hasDashedB4 = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disable_enemy()
	GlobalVars.connect("passed_tutorial", enable_enemy)
	GlobalVars.connect("has_moved", tut_move_done)
	$prompt_shoot.hide()
	
func enable_enemy():
	$TilemapTest/enemy.show()
	$TilemapTest/enemy.process_mode = Node.PROCESS_MODE_INHERIT
	$TilemapTest/EnemyBulletManager.process_mode = Node.PROCESS_MODE_INHERIT
	$prompt_harvest.hide()
	$prompt_shoot.show()
	$ui_fader.play_backwards("fade_out_shoot")
	
func disable_enemy():
	$TilemapTest/enemy.hide()
	$TilemapTest/enemy.process_mode = Node.PROCESS_MODE_DISABLED
	$TilemapTest/EnemyBulletManager.process_mode = Node.PROCESS_MODE_DISABLED
	
func tut_move_done():
	$ui_fader.play("fade_out_move")
	
func tut_dash_done():
	$ui_fader.play("fade_out_dash")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (not hasDashedB4 and Input.is_action_just_pressed("dash")):
		hasDashedB4 = true
		tut_dash_done()
