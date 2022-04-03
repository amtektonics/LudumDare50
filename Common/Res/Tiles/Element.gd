extends Area2D

class_name Element

signal selected

export var max_element_amount = 5

var _is_mouse_over = false

var _is_playable = false

var _element_amount = 1

var should_remove = false

func _ready():
	connect("input_event", self, "_input_event_area")
	connect("mouse_entered", self, "_mouse_entered_area")
	connect("mouse_exited", self, "_mouse_exited_area")


func _input_event_area(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if(_is_mouse_over && _is_playable):
			if(event.button_index == BUTTON_LEFT && event.pressed == true):
				emit_signal("selected", get_position())




func set_element_amount(value):
	_element_amount = value
	$ElementValue.text = str(_element_amount)

func get_element_amount():
	return _element_amount

func add_element_amount(value):
	_element_amount += value
	if(_element_amount > max_element_amount):
		_element_amount = max_element_amount
	$ElementValue.text = str(_element_amount)

func remove_element_amount(value):
	_element_amount -= value
	if(_element_amount <= 0):
		should_remove = true
	$ElementValue.text = str(_element_amount)

func show_selected(value:bool):
	$SelectorSprite.visible = value

func _mouse_entered_area():
	_is_mouse_over = true

func _mouse_exited_area():
	_is_mouse_over = false

func get_element():
	return null
