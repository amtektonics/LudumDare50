extends Node2D

onready var map = $Map_1


func _ready():
	center_camera()

func center_camera():
	$Camera2D.set_position(map.get_node("Center").get_position())
