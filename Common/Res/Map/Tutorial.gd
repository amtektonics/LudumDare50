extends Control


func _ready():
	$ResPannel.visible = true


func _on_ResNextBtn_pressed():
	$ResPannel.visible = false
	visible = false

func _on_FireTilleNextBtn_pressed():
	$FireTilePanel.visible = false
	visible = false


func show_fire_tile_info():
	visible = true
	$FireTilePanel.visible = true
