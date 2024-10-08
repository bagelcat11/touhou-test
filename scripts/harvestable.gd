extends Area2D

var grav = 3
var terminalVelocity = 13 * gravity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#global_position.y += gravity
	position += transform.y * grav
	if (global_position.y > get_viewport_rect().size.y + 50):
		print("freedom")
		queue_free()
	
func _on_area_entered(area: Node2D) -> void:
	#print("entered %s" % area)
	if area.is_in_group("harvesting_player"):
		GlobalVars.player_harvest.emit()
		queue_free()
