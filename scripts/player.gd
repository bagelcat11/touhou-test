extends CharacterBody2D

## == Refrences ==
@onready var modulationColor = self.modulate
@onready var double_tap_timer = $double_tap_window
@onready var floorcast = $floorcast
@export var player_bullet : PackedScene 
@export var dash_obj:PackedScene 
@onready var dash_timer = $dash_timer
@onready var dash_particles = $dash_particles
@onready var sprite = $sprite
@onready var bomb_vfx:PackedScene = preload("res://scenes/bomb_particles_v_2.tscn")
@onready var bomb_collider_hitbox = $bomb_clearing
@onready var animationPlayer = $AnimationPlayer
@export var screenshakeCamera:Camera2D

## == Physics Vars ==
var gravity = 40
var decelRate = 0.8
var terminalVelocity = 13 * gravity
@export var horizontalSpeed = 400


## == Jump Vars ==
@export var jumpForce = 550
var airSpeedDampening = 0.8


## == Movement Vars ==
var lastDirection # should this really be up here?

## Dashing Vars
@export var dash_speed = 1000
@export var dash_length = 0.2
var is_dashing: bool = false # currently dashing?
var can_dash: bool = true # can we legally dash?
var dash_direction: Vector2 # guh??? where are we dashing??

## Collecting Vars
@onready var isCollecting = false

## Bomb Vars
@export var bomb_duration:float = 2
var bomb_timer = 0
var is_bombing = false
@onready var has_bombed = false

## Cleanup Vars
var temp
@onready var hasMoved = false # uhhhhhhh

## == (legacy) Dashing Vars ==

#var isDashing # maybe this should be a state machine... # the state machine will be implemented soon™️ - kait
#var isDashRefreshed
#var dashVec = Vector2(0, 0)


func _ready() -> void:
	#GlobalVars.connect("enemy_hit", awesome)
	#isDashing = false
	#isDashRefreshed = true
	#dashVec = Vector2(0, 0)
	$basket/basket_sprite.hide()
	GlobalVars.current_lives = 6
	GlobalVars.current_num_harvested = 0 # CHANGE THIS BACK TO 0 LATER
	GlobalVars.current_num_bombs = 0

	GlobalVars.connect("player_harvest", harvest)
	dash_timer.connect("timeout", dash_timer_timeout)
	
	# what
	#add_to_group("harvesting_player")
	$basket.add_to_group("harvesting_player")
	#$hitbox.add_to_group("harvesting_player")
	#$hurtbox_area.add_to_group("harvesting_player")
	#$hurtbox_body.add_to_group("harvesting_player")
	#$jank_hitbox.add_to_group("harvesting_player")

func invincibility(time:float):
	$hurtbox_area.set_collision_layer_value(2,false)
	$hurtbox_body.set_collision_layer_value(2,false)
	$hurtbox_area.set_collision_mask_value(5,false)
	$hurtbox_body.set_collision_mask_value(5,false)
	animationPlayer.play("invincibilityFlash")
	await get_tree().create_timer(time).timeout
	animationPlayer.stop()
	sprite.modulate.a = 1
	$hurtbox_area.set_collision_layer_value(2,true)
	$hurtbox_body.set_collision_layer_value(2,true)
	$hurtbox_area.set_collision_mask_value(5,true)
	$hurtbox_body.set_collision_mask_value(5,true)

func get_dash_vector():
	var move_dir = Vector2()
	move_dir.x = Input.get_action_strength("ui_right") + -Input.get_action_strength("ui_left")
	move_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	# clamped so that we don't get the double speed if you hold down both keys
	move_dir = move_dir.normalized()
	print(move_dir)
	
	# if no input, dash forward
	if(move_dir == Vector2.ZERO):
		if(sprite.flip_h):
			move_dir.x = -1
		else:
			move_dir.x = 1


	return move_dir * dash_speed


func dash():
	if(Input.is_action_just_pressed("dash") and can_dash):
		$sfx_dash.play()
		sprite.modulate = Color.DARK_TURQUOISE
		invincibility(dash_length)
		is_dashing = true
		can_dash = false
		dash_direction = get_dash_vector()
		dash_timer.start(dash_length)
	
	if(is_dashing):
		var dash_node = dash_obj.instantiate()
		dash_node.texture = sprite
		dash_node.global_position = global_position
		dash_node.flip_h = sprite.flip_h
		get_parent().add_child(dash_node)
		
		dash_particles.emitting = true
		#if(is_on_floor()):
			#is_dashing = false
	else:
		dash_particles.emitting = false
	
func die():
	$sfx_die.play()
	animationPlayer.play("death")
	GlobalVars.emit_signal("death")
	
	
func harvest():
	#print("gottem")
	$sfx_harvest.play()
	GlobalVars.score += 1000
	GlobalVars.current_num_harvested += 1
	#if (GlobalVars.current_num_harvested == 1):
		#GlobalVars.has_moved.emit()
	if (GlobalVars.current_num_harvested == 3):
		GlobalVars.passed_tutorial.emit()
	if (GlobalVars.current_num_harvested == GlobalVars.apples_per_bomb):
		GlobalVars.first_bomb.emit()
	if (GlobalVars.current_num_harvested % int(GlobalVars.apples_per_bomb) == 0 and GlobalVars.current_num_bombs < 5):
		GlobalVars.current_num_bombs += 1
		$sfx_bomb_up.play()

#speed is actually how quickly the circle lerps out so keep it very small
func summon_bomb(s):
	$sfx_use_bomb.play()
	var currSpawner = bomb_vfx.instantiate()
	currSpawner.position.x = 0
	currSpawner.position.y = 0
	currSpawner.speed = s
	screenshakeCamera.apply_shake()
	add_child(currSpawner)
	return currSpawner

# remove the underscore on delta if you end up using it
func _physics_process(delta):
	
	## DEBUG DEATH
	if(Input.is_action_just_pressed("debug_death")):
		die()
	
	if(velocity.x < 0):
		sprite.flip_h = true
	elif(velocity.x > 0):
		sprite.flip_h = false
		
	
	#print(velocity)
	dash()
	#print(dash_direction)
	# == Fall Through ==
	#if(Input.is_action_just_pressed("drop_through")):
		#if(floorcast.is_colliding()):
			#if(floorcast.get_collider().name == "Platforms"):
				#drop()
	# == Bomb ==
	if(Input.is_action_just_pressed("bomb") and not is_bombing and GlobalVars.current_num_bombs > 0):
		if (not has_bombed):
			has_bombed = true
			GlobalVars.bomb_tut_done.emit()
		invincibility(bomb_duration)
		GlobalVars.current_num_bombs -= 1
		var curr_width = get_viewport().get_visible_rect().size.x
		var curr_height =get_viewport().get_visible_rect().size.y
		is_bombing = true
		bomb_collider_hitbox.set_collision_mask_value(5,true)
		bomb_collider_hitbox.set_collision_layer_value(2,true)
		temp = summon_bomb(1.0 / 3.0)
	if(is_bombing):
		bomb_timer += delta
		bomb_collider_hitbox.scale = lerp(bomb_collider_hitbox.scale, Vector2(100,100), 0.005)
		if(bomb_timer > bomb_duration):
			temp.queue_free()
			is_bombing = false
			bomb_timer = 0
			bomb_collider_hitbox.scale = Vector2(1,1)
			bomb_collider_hitbox.set_collision_mask_value(5,false)
			bomb_collider_hitbox.set_collision_layer_value(2,false)
			
	# == Hold to Fall ==
	if(Input.is_action_pressed("drop_through")):
		self.set_collision_mask_value(4,false)
	if(Input.is_action_just_released("drop_through")):
		self.set_collision_mask_value(4,true)
		
	
	# == FALLING ==
	gravity = 40 * (1 + 0.75 * Input.get_action_strength("ui_down"))
	terminalVelocity = 13 * gravity
	if (!is_on_floor()): #and not is dashing
		velocity.y += gravity
		if (velocity.y > terminalVelocity):
			velocity.y = terminalVelocity
	
	# == JUMPING / WALLJUMPING ==
	# negative because -y is up
	# and not is dashing
	if (Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall())):
		velocity.y = -jumpForce
		$sfx_jump.play()
		
	# == SHOOTING/COLLECTING ==
	if (Input.is_action_pressed("shoot")):
		# stop all collecting stuff while shooting
		isCollecting = false
		$basket/basket_sprite.hide()
		$basket.hide()
		#remove_from_group("harvesting_player")
		$basket.remove_from_group("harvesting_player")
		#$hitbox.remove_from_group("harvesting_player")
		#$hurtbox_area.remove_from_group("harvesting_player")
		#$hurtbox_body.remove_from_group("harvesting_player")
		#$jank_hitbox.remove_from_group("harvesting_player")
		
		# actual shooting code
		if ($shot_cooldown.is_stopped()):
			$sfx_shoot.play()
			var b = player_bullet.instantiate()	# 5 dam for non-focus homing mode
			owner.add_child(b)
			b.transform = $bullet_emitter.global_transform
			$shot_cooldown.start()
	else:
		isCollecting = true
		$basket/basket_sprite.show()
		$basket.show()
		#add_to_group("harvesting_player")
		$basket.add_to_group("harvesting_player")
		#$hitbox.add_to_group("harvesting_player")
		#$hurtbox_area.add_to_group("harvesting_player")
		#$hurtbox_body.add_to_group("harvesting_player")
		#$jank_hitbox.add_to_group("harvesting_player")
		
	# == AIMING ==
	# uhhhhhhhhhhh
	if (get_parent().get_node("enemy")):
		$bullet_emitter.look_at(Vector2(get_parent().get_node("enemy").position))
	else:
		$bullet_emitter.set_global_rotation(-PI/2)
		
	## == COLLECTING ==
	#if (Input.is_action_pressed("basket")):
		## TODO: have bool var for isCollecting? 
		## can't i just make the group apply recursively or smth
		#
		
	#else:
		#
		##
	
	# == MOVING ==
	# move_left returns -1, move_right returns 1
	var horizontalDirection = 0
	if (Input.is_action_just_pressed("move_left")):
		horizontalDirection = -1
		lastDirection = -1
	elif (Input.is_action_just_pressed("move_right")):
		horizontalDirection = 1
		lastDirection = 1
	
	# what
	if (Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right")):
		if (Input.is_action_pressed("move_left")):
			lastDirection = -1
		elif (Input.is_action_pressed("move_right")):
			lastDirection = 1
		else:
			lastDirection = 0
		if (not hasMoved): # uhhhhhhhhhhh
			hasMoved = true
			GlobalVars.has_moved.emit()

	if (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")): # and not is dashing
		horizontalDirection = lastDirection
		if (is_on_floor() and not $sfx_walk.playing):
			$sfx_walk.play()
		
	
	if (is_on_floor() and not can_dash and not is_dashing):
		can_dash = true
		#isDashRefreshed = true
	# == MANAGING DASH STATE ==
	# im gonna try celeste maxxing the dash really quickly
	#if (is_on_floor() and not isDashRefreshed and $dash_cooldown.is_stopped()):
		#isDashRefreshed = true
	#if (not is_on_floor() and not $dash_cooldown.is_stopped()):
		#$dash_cooldown.stop()
	#if ($dash_timer.is_stopped()):
		#isDashing = false
		#dashVec = Vector2(0, 0)
	#if (not isDashRefreshed):
		#$sprite.modulate = Color.from_hsv(0.5, 0.5, 1)
	#else:
		#$sprite.modulate = modulationColor
		#
	## == DASHING ==
	## TODO: MAKE THIS ACTUALLY WORK IN A NORMAL WAY
	#if (Input.is_action_just_pressed("dash") and isDashRefreshed):
		#velocity = dashVec
		#isDashing = true
		#isDashRefreshed = false
		#$dash_timer.start()
		#$dash_cooldown.start()
		#dashVec.x = horizontalDirection
		#if (Input.is_action_pressed("jump") and not Input.is_key_pressed(KEY_DOWN)):
			#dashVec.y = -1
		#if (Input.is_key_pressed(KEY_DOWN) and not Input.is_action_pressed("jump")):
			#dashVec.y = 1
	#
	#if (isDashing):
		#if (dashVec.y == 0): # if only dashing horizontally, extend
			#velocity = Vector2(dashSpeed * 1.6 * dashVec.x, 0)
		#else:
			#velocity = Vector2(dashSpeed * dashVec.x, dashSpeed * dashVec.y)
	
	#implement the dash
	if(is_dashing):
		velocity = dash_direction

	
	

	# == VELOCITY UPDATE ==
	# oops i spaghettified this
	if (horizontalDirection and not is_dashing): # and not is dashing
		if (is_on_floor() or is_on_wall()):
			velocity.x = horizontalSpeed * horizontalDirection
		else:
			velocity.x = horizontalSpeed * horizontalDirection * airSpeedDampening
	else: # if not inputting, decel
		if (not is_dashing):
			velocity.x = move_toward(velocity.x, 0, horizontalSpeed * decelRate)
			
	#get_parent().get_node("TEST_TEXT").text = "dashVec: (%s, %s)\nisDashing: %s\nisDashRefreshed: %s" % [dashVec.x, dashVec.y, isDashing, isDashRefreshed]
		


	move_and_slide()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	$sfx_get_hit.play()
	invincibility(1.5)
	screenshakeCamera.apply_shake()
	print(GlobalVars.current_lives)
	GlobalVars.current_lives -= 1
	GlobalVars.lost_health.emit(GlobalVars.current_lives)
	if (GlobalVars.current_lives <= 0):
		GlobalVars.emit_signal("enemy_bullet_clear")
		die()

func dash_timer_timeout():
	sprite.modulate = Color.WHITE
	velocity = Vector2(
		clampf(velocity.x, -horizontalSpeed, horizontalSpeed), 
		clampf(velocity.y, -275, terminalVelocity)
	)
	is_dashing = false
