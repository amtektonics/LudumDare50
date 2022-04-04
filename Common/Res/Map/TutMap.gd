extends GameMap


func _startup_map():
	add_element(Globals.Elements.FIRE, Vector2(1, 1), 2)
	add_element(Globals.Elements.WATER, Vector2(2, 1), 1)
	
	_placing_count = 3
	
	show_placing_text()
	
	connect("enter_move_phase", self, "_enter_move_phase")



func _enter_move_phase():
	if(_turn_counter == 1):
		$CanvasLayer/Tutorial.show_fire_tile_info()
