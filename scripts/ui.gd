extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$life1.show()
	$life2.show()
	$life3.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (GlobalVars.current_lives < 3):
		$life3.hide()
		if (GlobalVars.current_lives < 2):
			$life2.hide()
			if (GlobalVars.current_lives < 1):
				$life1.hide()
	else:
		$life1.show()
		$life2.show()
		$life3.show()
