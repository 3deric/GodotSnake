extends Node2D

signal restart

func _on_button_pressed():
	restart.emit()
