extends Area2D

var grav = 4
var terminalVelocity = 13 * gravity
var isInBody
var currentEnteredArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	isInBody = false
	currentEnteredArea = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#global_position.y += gravity
	position += transform.y * grav
	if (global_position.y > get_viewport_rect().size.y + 50):
		print("freedom")
		queue_free()
		
	if (isInBody and currentEnteredArea.is_in_group("harvesting_player")):
		#print("gottem in wrong script")
		GlobalVars.player_harvest.emit()
		queue_free()
	
func _on_area_entered(area: Node2D) -> void:
	print("entered %s" % area)
	isInBody = true
	currentEnteredArea = area
	#print("entered %s" % area)


func _on_area_exited(area: Area2D) -> void:
	isInBody = false
	currentEnteredArea = null
