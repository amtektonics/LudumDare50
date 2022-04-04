extends GameMap


func _startup_map():
	add_element(Globals.Elements.FIRE, Vector2(1, 1), 1)
	_placing_count = 2
	
	show_placing_text()
