extends Node2D

var _current_map

func _ready():
	center_camera()

func center_camera():
	if(_current_map != null):
		$Camera2D.set_position(_current_map.get_node("Center").get_position())

func clear_map():
	if(_current_map != null):
		_current_map.queue_free()
		_current_map = null
		$CanvasLayer/Menu.visible = true

func _on_Tutorial_pressed():
	_current_map = load("res://Common/Res/Map/Tutorial.tscn").instance()
	$CanvasLayer/Menu.visible = false
	add_child(_current_map)
	center_camera()


func _on_Level1_pressed():
	_current_map = load("res://Common/Res/Map/Map_1.tscn").instance()
	$CanvasLayer/Menu.visible = false
	add_child(_current_map)
	center_camera()


func _on_Level2_pressed():
	pass # Replace with function body.
	_current_map = load("res://Common/Res/Map/Map_2.tscn").instance()
	$CanvasLayer/Menu.visible = false
	add_child(_current_map)
	center_camera()

func _on_Level3_pressed():
	pass # Replace with function body.
	_current_map = load("res://Common/Res/Map/Map_3.tscn").instance()
	$CanvasLayer/Menu.visible = false
	add_child(_current_map)
	center_camera()
	
func _on_Level4_pressed():
	_current_map = load("res://Common/Res/Map/Map_4.tscn").instance()
	$CanvasLayer/Menu.visible = false
	add_child(_current_map)
	center_camera()
