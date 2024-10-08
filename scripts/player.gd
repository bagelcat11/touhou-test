extends CharacterBody2D

@export var horizontalSpeed = 400
var gravity = 40
@export var jumpForce = 550
var airSpeedDampening = 0.8
@export var dashSpeed = 1000
var decelRate = 0.8
var terminalVelocity = 13 * gravity
var lastDirection # should this really be up here?
var isDashing # maybe this should be a state machine...
var isDashRefreshed
var dashVec = Vector2(0, 0)

@export var player_bullet : PackedScene

func _ready() -> void:
	#GlobalVars.connect("enemy_hit", awesome)
	isDashing = false
	isDashRefreshed = true
	dashVec = Vector2(0, 0)
	$basket/basket_sprite.hide()


# remove the underscore on delta if you end up using it
func _physics_process(_delta):
	
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
		
	# == AIMING (TEMP?) ==
	# uhhhhhhhhhhh
	if (get_parent().get_node("enemy")):
		$bullet_emitter.look_at(Vector2(get_parent().get_node("enemy").position))
	else:
		$bullet_emitter.set_global_rotation(-PI/2)
		
	# == COLLECTING ==
	if (Input.is_action_pressed("basket")):
		# TODO: have bool var for isCollecting? 
		$basket/basket_sprite.show()
	else:
		$basket/basket_sprite.hide()
	
	# == MOVING ==
	# move_left returns -1, move_right returns 1
	var horizontalDirection = 0#= Input.get_axis("move_left", "move_right")
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

	if (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
		horizontalDirection = lastDirection
		
	# == MANAGING DASH STATE ==
	if (is_on_floor() and not isDashRefreshed and $dash_cooldown.is_stopped()):
		isDashRefreshed = true
	if ($dash_cooldown.is_stopped()):
		isDashing = false
		dashVec = Vector2(0, 0)
		
	# == DASHING ==
	# TODO: MAKE THIS ACTUALLY WORK IN A NORMAL WAY
	if (Input.is_action_just_pressed("dash") and isDashRefreshed):
		velocity = dashVec
		isDashing = true
		isDashRefreshed = false
		$dash_cooldown.start()
		dashVec.x = horizontalDirection
		if (Input.is_action_pressed("jump") and not Input.is_key_pressed(KEY_DOWN)):
			dashVec.y = -1
		if (Input.is_key_pressed(KEY_DOWN) and not Input.is_action_pressed("jump")):
			dashVec.y = 1
	
	if (isDashing):
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
			
	get_parent().get_node("TEST_TEXT").text = "dashVec: (%s, %s)\nisDashing: %s\nisDashRefreshed: %s" % [dashVec.x, dashVec.y, isDashing, isDashRefreshed]
		


	move_and_slide()
