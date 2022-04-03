extends GameMap


func _startup_map():
	add_element(Globals.Elements.FIRE, Vector2(1, 1), 5)
	add_element(Globals.Elements.WATER, Vector2(2, 1), 2)
