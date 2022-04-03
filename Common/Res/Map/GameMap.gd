extends Node2D

class_name GameMap

export var turns_until_ff = 10

var _turn_counter = 1

var element_tiles = {}

onready var _tile_map = $TileMap

var _selected = null

var _must_wait = false

func _ready():
	_startup_map()


func _startup_map():
	pass

func _input(event):
	if event is InputEventMouseButton:
		if(event.button_index == BUTTON_LEFT && event.pressed):
			if(_selected != null && !_must_wait):
				var t_pos = _tile_map.world_to_map(get_global_mouse_position())
				if(t_pos != _selected):
					var element = element_tiles[_selected].get_element()
					if(is_valid_tile(element, t_pos)):
						transfer_element(_selected, t_pos)
						call_deferred("clear_selected")
						_must_wait = true
				else:
					call_deferred("clear_selected")
					_must_wait = true

func _process(delta):
	if(_must_wait):
		_must_wait = false

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
		if(e == element_tiles[Vector2(t_pos.x + 1, t_pos.y)].get_element()):
			valid_neighbors.append(Vector2(t_pos.x + 1, t_pos.y))
	
	if(element_tiles.has(Vector2(t_pos.x, t_pos.y + 1))):
		if(e == element_tiles[Vector2(t_pos.x, t_pos.y + 1)].get_element()):
			valid_neighbors.append(Vector2(t_pos.x, t_pos.y + 1))
	
	if(element_tiles.has(Vector2(t_pos.x - 1, t_pos.y))):
		if(e == element_tiles[Vector2(t_pos.x- 1, t_pos.y)].get_element()):
			valid_neighbors.append(Vector2(t_pos.x - 1, t_pos.y))
	
	if(element_tiles.has(Vector2(t_pos.x, t_pos.y - 1))):
		if(e == element_tiles[Vector2(t_pos.x, t_pos.y - 1)].get_element()):
			valid_neighbors.append(Vector2(t_pos.x, t_pos.y - 1))
	
	return valid_neighbors

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

#signals
func _e_selected(w_pos):
	if(!_selected):
		var t_pos = _tile_map.world_to_map(w_pos)
		if(element_tiles[t_pos].get_element_amount() > 1):
			_selected = t_pos
			element_tiles[_selected].show_selected(true)
