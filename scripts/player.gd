extends CharacterBody2D

@export var horizontalSpeed = 400
@export var gravity = 40
@export var jumpForce = 550
@export var airSpeedDampening = 0.8
@export var dashSpeed = 1000
@export var decelRate = 0.05
var terminalVelocity = 13 * gravity


# remove the underscore on delta if you end up using it
func _physics_process(delta):
	
	# == FALLING ==
	if (!is_on_floor()):
		velocity.y += gravity
		if (velocity.y > terminalVelocity):
			velocity.y = terminalVelocity
	
	# == JUMPING / WALLJUMPING ==
	# negative because -y is up
	if (Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall())):
		velocity.y = -jumpForce
	
	# == DASHING ==
	#if (Input.is_action_just_pressed("dash")):
		#pass
#		print("dashed")
		# add things here!!
	
	# == MOVING ==
	# move_left returns -1, move_right returns 1
	var horizontalDirection = Input.get_axis("move_left", "move_right")
	
	# == VELOCITY UPDATE ==
	if (horizontalDirection):
		if (is_on_floor() or is_on_wall()):
			velocity.x = horizontalSpeed * horizontalDirection
		else:
			velocity.x = horizontalSpeed * horizontalDirection * airSpeedDampening
	else: # if not inputting, decel
		velocity.x = move_toward(velocity.x, 0, horizontalSpeed * decelRate)
		

	move_and_slide()
