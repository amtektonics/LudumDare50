extends Node2D

class_name GameMap

export var turns_until_ff = 10

enum GameStates{
	PLACING,
	MOVING,
	AWIATING
}
enum AIOPS{
	PLACE,
	DELAY
}

signal enter_move_phase

var element_tiles = {}

onready var _tile_map = $TileMap

var _turn_counter = 1

var _is_players_turn = true

var _selected = null

var _must_wait = false

var _current_game_state = GameStates.PLACING

var _placing_count = 0

var _ai_steps = []

func _ready():
	randomize()
	_startup_map()
	update_placing_ui()
	$PlacingTimer.connect("timeout", self, "_hide_placing_text")
	$MoveTimer.connect("timeout", self, "_hide_move_text")
	$CanvasLayer/NextPhaseBtn.connect("pressed", self, "_next_phase_pressed")
	$CanvasLayer/WinLose/CC/WinC/BackToMenuBtn.connect("pressed", self, "_back_to_menu")
	$CanvasLayer/WinLose/CC/LoseC/BackToMenuBtn.connect("pressed", self, "_back_to_menu")

func _back_to_menu():
	get_node("/root/Node/GameWorld").clear_map()

func _startup_map():
	pass

func _input(event):
	if event is InputEventMouseButton:
		if(event.button_index == BUTTON_LEFT && event.pressed):
			if(!_must_wait):
				var t_pos = _tile_map.world_to_map(get_global_mouse_position())
				if(_current_game_state == GameStates.MOVING):
						_handle_movement(t_pos)
				elif(_current_game_state == GameStates.PLACING):
					_handle_placing(t_pos)
				else:
					pass

func _handle_placing(t_pos):
	if(_placing_count > 0):
		if(element_tiles.has(t_pos)):
			if(element_tiles[t_pos].get_element() == Globals.Elements.FIRE):
				if(element_tiles[t_pos].get_element_amount() < element_tiles[t_pos].max_element_amount):
					add_element(Globals.Elements.FIRE, t_pos)
					_placing_count -= 1
					update_placing_ui()
					_must_wait = true

func _handle_movement(t_pos):
	if(_selected != null):
		if(t_pos != _selected):
			var element = element_tiles[_selected].get_element()
			if(is_valid_tile(element, t_pos)):
				transfer_element(_selected, t_pos)
				call_deferred("clear_selected")
				_must_wait = true
		else:
			call_deferred("clear_selected")
			_must_wait = true

func step_phase():
	if(_current_game_state == GameStates.PLACING):
		_current_game_state = GameStates.MOVING
		show_move_text()
		emit_signal("enter_move_phase")
	
	elif(_current_game_state == GameStates.MOVING):
		_current_game_state = GameStates.AWIATING
		show_ai_turn_text()
		$CanvasLayer/NextPhaseBtn.disabled = true
		
	elif(_current_game_state == GameStates.AWIATING):
		hide_ai_turn_text()
		show_placing_text()
		_current_game_state = GameStates.PLACING
		$CanvasLayer/NextPhaseBtn.disabled = false
		_turn_counter += 1
		update_turn_counter()
		var value = (get_element_count(Globals.Elements.FIRE) - (_turn_counter))
		if(value <= 0):
			$CanvasLayer/WinLose.visible = true
			$CanvasLayer/WinLose/CC/LoseC.visible = true
		else:
			_placing_count += value + 2
		update_placing_ui()

func _process(delta):
	if(_must_wait):

		_must_wait = false
	
	if(_current_game_state == GameStates.PLACING && _placing_count == 0):
		step_phase()
		_must_wait = true
	
	if(_current_game_state == GameStates.AWIATING):
		for t in element_tiles:
			if(element_tiles[t].get_element() == Globals.Elements.WATER):
				add_element(Globals.Elements.WATER, t)
			
		for i in range(0, _turn_counter):
			var p_pos = get_valid_water_placement()
			
			if(p_pos.size() == 0):
				break
			
			var j = rand_range(0, p_pos.size() - 1)
			add_element(Globals.Elements.WATER, p_pos[j])
			
		for t in element_tiles:
			if(element_tiles[t].get_element() == Globals.Elements.WATER):
				if(element_tiles[t].get_element_amount() > 1):
					var valid = _tile_map.get_used_cells_by_id(0)
					var ii = rand_range(0, valid.size() - 1)
					var target = valid[ii]
					if(target != null):
						transfer_element(t, target)
		
		_must_wait = true
		
		step_phase()
	for t_pos in element_tiles:
		if(element_tiles[t_pos].get_element_amount() <= 0):
			element_tiles[t_pos].kill_element()
			element_tiles.erase(t_pos)
	
	var fire_counter = 0
	for e in element_tiles:
		if(element_tiles[e].get_element() == Globals.Elements.FIRE):
			fire_counter += 1
	
	if(_tile_map.get_used_cells_by_id(0).size() == fire_counter):
		$CanvasLayer/WinLose.visible = true
		$CanvasLayer/WinLose/CC/WinC.visible = true
		$CanvasLayer/WinLose/CC/WinC/WinInfo.text = "Within " + str(_turn_counter) + " Turns"

func is_valid_tile(e, tile:Vector2):
	if(_tile_map.get_cellv(tile) != 0):
		return false
	
	var d = tile.distance_to(_selected)
	
	if(d > 1 && !element_tiles.has(tile)):
		return false
	
	if(element_tiles.has(tile) && !is_element_connected(e, _selected, tile)):
		return false
	
	return true

func is_element_connected(element, start, end):
	var connected_elements = []
	var needs_to_be_tested = []
	var testing_add_queue = []
	var result = false
	
	testing_add_queue.append_array(get_element_neighbors(element, start))
	
	needs_to_be_tested.append_array(testing_add_queue)
	
	while(needs_to_be_tested.size() > 0):
		connected_elements.append_array(needs_to_be_tested)
		
		for c in connected_elements:
			if(c == end):
				result = true
				break
				
		if(result == true):
			break
		
		testing_add_queue.clear()
		
		for p in needs_to_be_tested:
			testing_add_queue.append_array(get_element_neighbors(element, p))
		
		needs_to_be_tested.clear()
		
		for tp in testing_add_queue:
			if(connected_elements.has(tp)):
				continue
			needs_to_be_tested.append(tp)
			
	return result

func get_element_neighbors(e, t_pos):
	var valid_neighbors = []
	if(element_tiles.has(Vector2(t_pos.x + 1, t_pos.y))):
#		if(e == element_tiles[Vector2(t_pos.x + 1, t_pos.y)].get_element()):
		valid_neighbors.append(Vector2(t_pos.x + 1, t_pos.y))
	
	if(element_tiles.has(Vector2(t_pos.x, t_pos.y + 1))):
#		if(e == element_tiles[Vector2(t_pos.x, t_pos.y + 1)].get_element()):
		valid_neighbors.append(Vector2(t_pos.x, t_pos.y + 1))
	
	if(element_tiles.has(Vector2(t_pos.x - 1, t_pos.y))):
#		if(e == element_tiles[Vector2(t_pos.x- 1, t_pos.y)].get_element()):
		valid_neighbors.append(Vector2(t_pos.x - 1, t_pos.y))
	
	if(element_tiles.has(Vector2(t_pos.x, t_pos.y - 1))):
#		if(e == element_tiles[Vector2(t_pos.x, t_pos.y - 1)].get_element()):
		valid_neighbors.append(Vector2(t_pos.x, t_pos.y - 1))
	
	return valid_neighbors

func get_valid_water_neigbors(t_pos):
	var valid = []
	var valid_cells = _tile_map.get_used_cells_by_id(0)
	#
	if(!element_tiles.has(Vector2(t_pos.x + 1, t_pos.y))):
		if(valid_cells.has(Vector2(t_pos.x + 1, t_pos.y))):
			valid.append(Vector2(t_pos.x + 1, t_pos.y))
	else:
		if(element_tiles[Vector2(t_pos.x + 1, t_pos.y)].get_element() == Globals.Elements.FIRE):
			valid.append(Vector2(t_pos.x + 1, t_pos.y))
	#
	if(!element_tiles.has(Vector2(t_pos.x, t_pos.y + 1))):
		if(valid_cells.has(Vector2(t_pos.x, t_pos.y + 1))):
			valid.append(Vector2(t_pos.x, t_pos.y + 1))
	else:
		if(element_tiles[Vector2(t_pos.x, t_pos.y + 1)].get_element() == Globals.Elements.FIRE):
			valid.append(Vector2(t_pos.x, t_pos.y + 1))
	#
	if(!element_tiles.has(Vector2(t_pos.x - 1, t_pos.y))):
		if(valid_cells.has(Vector2(t_pos.x - 1, t_pos.y))):
			valid.append(Vector2(t_pos.x - 1, t_pos.y))	
	else:
		if(element_tiles[Vector2(t_pos.x - 1, t_pos.y)].get_element() == Globals.Elements.FIRE):
			valid.append(Vector2(t_pos.x - 1, t_pos.y))
	#
	if(!element_tiles.has(Vector2(t_pos.x, t_pos.y - 1))):
		if(valid_cells.has(Vector2(t_pos.x, t_pos.y - 1))):
			valid.append(Vector2(t_pos.x, t_pos.y - 1))
	else:
		if(element_tiles[Vector2(t_pos.x, t_pos.y - 1)].get_element() == Globals.Elements.FIRE):
			valid.append(Vector2(t_pos.x, t_pos.y - 1))
	
	return valid

func get_valid_water_placement():
	var floor_cells = _tile_map.get_used_cells_by_id(0)
	var valid_cells = []
	for c in floor_cells:
		if(element_tiles.has(c)):
			if(element_tiles[c].get_element() == Globals.Elements.WATER):
				valid_cells.append(c)
		else:
			valid_cells.append(c)
	return valid_cells

func get_element_count(element):
	var count = 0
	for t in element_tiles:
		if(element_tiles[t].get_element() == element):
			count += 1
	return count

func add_element(e, t_pos:Vector2, amount=1):
	var e_node
	if(element_tiles.has(t_pos)):
		var target_element = element_tiles[t_pos]
		if(e == target_element.get_element()):
			target_element.add_element_amount(amount)
		elif(e != target_element.get_element()):
			target_element.remove_element_amount(amount)
	else:
		if(e == Globals.Elements.FIRE):
			e_node = load("res://Common/Res/Tiles/Fire.tscn").instance()
		elif(e == Globals.Elements.WATER):
			e_node = load("res://Common/Res/Tiles/Water.tscn").instance()
		
		e_node.connect("selected", self, "_e_selected")
		
		var w_pos = _tile_map.map_to_world(t_pos) + (_tile_map.cell_size / 2)
		
		e_node.set_element_amount(amount)
		
		e_node.set_position(w_pos)
		
		add_child(e_node)
		
		element_tiles[t_pos] = e_node

func remove_element(t_pos:Vector2, amount = 1):
	
	if(element_tiles.has(t_pos)):
		var target = element_tiles[t_pos]
		target.remove_element_amount(amount)
#start here
func transfer_element(origin, target):
	if(element_tiles.has(origin)):
		var oet = element_tiles[origin]
		remove_element(origin)
		add_element(oet.get_element(), target)

func clear_selected():
	element_tiles[_selected].show_selected(false)
	_selected = null

func is_element(element, t_pos:Vector2):
	if(element_tiles.has(t_pos)):
		if(element_tiles[t_pos].get_element() == element):
			return true
	return false

func show_placing_text():
	$CanvasLayer/CC/Movement.visible = false
	$CanvasLayer/CC/Placing.visible = true
	$PlacingTimer.start()

func show_move_text():
	$CanvasLayer/CC/Placing.visible = false
	$CanvasLayer/CC/Movement.visible = true
	$MoveTimer.start()

func show_ai_turn_text():
	$CanvasLayer/CC/AITurn.visible = true

func hide_ai_turn_text():
	$CanvasLayer/CC/AITurn.visible = false

func update_placing_ui():
	$CanvasLayer/Placeable/Amount.text = str(_placing_count)

func update_turn_counter():
	$CanvasLayer/Turn.text = "Turn: " + str(_turn_counter)

#signals
func _e_selected(w_pos):
	if(!_selected):
		var t_pos = _tile_map.world_to_map(w_pos)
		if(element_tiles[t_pos].get_element_amount() > 1):
			if(_current_game_state == GameStates.MOVING):
				_selected = t_pos
				element_tiles[_selected].show_selected(true)

func _hide_placing_text():
	$CanvasLayer/CC/Placing.visible = false

func _hide_move_text():
	$CanvasLayer/CC/Movement.visible = false

func _next_phase_pressed():
	step_phase()
