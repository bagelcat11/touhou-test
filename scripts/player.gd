extends CharacterBody2D

@export var horizontalSpeed = 400
var gravity = 40
@export var jumpForce = 550
var airSpeedDampening = 0.8
@export var dashSpeed = 500 #1000
var decelRate = 0.8
var terminalVelocity = 13 * gravity
var lastDirection # should this really be up here?
var isDashing # maybe this should be a state machine...
var isDashRefreshed
var dashVec = Vector2(0, 0)
@onready var modulationColor = self.modulate

@onready var double_tap_timer = $double_tap_window
@onready var floorcast = $floorcast

@export var player_bullet : PackedScene

func _ready() -> void:
	#GlobalVars.connect("enemy_hit", awesome)
	isDashing = false
	isDashRefreshed = true
	dashVec = Vector2(0, 0)
	$basket/basket_sprite.hide()
	GlobalVars.connect("player_harvest", harvest)
	add_to_group("harvesting_player")
	$basket.add_to_group("harvesting_player")
	$hitbox.add_to_group("harvesting_player")
	#$hurtbox_area.add_to_group("harvesting_player")
	#$hurtbox_body.add_to_group("harvesting_player")


func drop():
	position.y += 1
	
func harvest():
	print("harvested")
	

# remove the underscore on delta if you end up using it
func _physics_process(_delta):
	
	# == Fall Through ==
	#if(Input.is_action_just_pressed("drop_through")):
		#if(floorcast.is_colliding()):
			#if(floorcast.get_collider().name == "Platforms"):
				#drop()
	# == Hold to Fall ==
	if(Input.is_action_pressed("drop_through")):
		self.set_collision_mask_value(4,false)
	if(Input.is_action_just_released("drop_through")):
		self.set_collision_mask_value(4,true)
		
	
	# == FALLING ==
	if (!is_on_floor() and not isDashing):
		velocity.y += gravity
		if (velocity.y > terminalVelocity):
			velocity.y = terminalVelocity
	
	# == JUMPING / WALLJUMPING ==
	# negative because -y is up
	if (Input.is_action_just_pressed("jump") and not isDashing and (is_on_floor() or is_on_wall())):
		velocity.y = -jumpForce
		
	# == SHOOTING ==
	if (Input.is_action_pressed("shoot") and $shot_cooldown.is_stopped()):
		var b = player_bullet.instantiate()	# 5 dam for non-focus homing mode
		owner.add_child(b)
		b.transform = $bullet_emitter.global_transform
		$shot_cooldown.start()
		
	# == AIMING ==
	# uhhhhhhhhhhh
	if (get_parent().get_node("enemy")):
		$bullet_emitter.look_at(Vector2(get_parent().get_node("enemy").position))
	else:
		$bullet_emitter.set_global_rotation(-PI/2)
		
	# == COLLECTING ==
	if (Input.is_action_pressed("basket")):
		# TODO: have bool var for isCollecting? 
		# can't i just make the group apply recursively or smth
		$basket/basket_sprite.show()
		$basket.show()
		add_to_group("harvesting_player")
		$basket.add_to_group("harvesting_player")
		$hitbox.add_to_group("harvesting_player")
		#$hurtbox_area.add_to_group("harvesting_player")
		#$hurtbox_body.add_to_group("harvesting_player")
	else:
		$basket/basket_sprite.hide()
		$basket.hide()
		remove_from_group("harvesting_player")
		$basket.remove_from_group("harvesting_player")
		$hitbox.remove_from_group("harvesting_player")
		#$hurtbox_area.remove_from_group("harvesting_player")
		#$hurtbox_body.remove_from_group("harvesting_player")
	
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

	if (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") and not isDashing):
		horizontalDirection = lastDirection
		
	# == MANAGING DASH STATE ==
	if (is_on_floor() and not isDashRefreshed and $dash_cooldown.is_stopped()):
		isDashRefreshed = true
	if (not is_on_floor() and not $dash_cooldown.is_stopped()):
		$dash_cooldown.stop()
	if ($dash_timer.is_stopped()):
		isDashing = false
		dashVec = Vector2(0, 0)
	if (not isDashRefreshed):
		$sprite.modulate = Color.from_hsv(0.5, 0.5, 1)
	else:
		$sprite.modulate = modulationColor
		
	# == DASHING ==
	# TODO: MAKE THIS ACTUALLY WORK IN A NORMAL WAY
	if (Input.is_action_just_pressed("dash") and isDashRefreshed):
		velocity = dashVec
		isDashing = true
		isDashRefreshed = false
		$dash_timer.start()
		$dash_cooldown.start()
		dashVec.x = horizontalDirection
		if (Input.is_action_pressed("jump") and not Input.is_key_pressed(KEY_DOWN)):
			dashVec.y = -1
		if (Input.is_key_pressed(KEY_DOWN) and not Input.is_action_pressed("jump")):
			dashVec.y = 1
	
	if (isDashing):
		if (dashVec.y == 0): # if only dashing horizontally, extend
			velocity = Vector2(dashSpeed * 1.6 * dashVec.x, 0)
		else:
			velocity = Vector2(dashSpeed * dashVec.x, dashSpeed * dashVec.y)

	# == VELOCITY UPDATE ==
	# oops i spaghettified this
	if (horizontalDirection and not isDashing):
		if (is_on_floor() or is_on_wall()):
			velocity.x = horizontalSpeed * horizontalDirection
		else:
			velocity.x = horizontalSpeed * horizontalDirection * airSpeedDampening
	else: # if not inputting, decel
		if (not isDashing):
			velocity.x = move_toward(velocity.x, 0, horizontalSpeed * decelRate)
			
	#get_parent().get_node("TEST_TEXT").text = "dashVec: (%s, %s)\nisDashing: %s\nisDashRefreshed: %s" % [dashVec.x, dashVec.y, isDashing, isDashRefreshed]
		


	move_and_slide()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("ouchies") # Replace with function body.
