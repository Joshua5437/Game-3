extends Control

signal go_back_pressed

func _on_Button_pressed():
	emit_signal("go_back_pressed")
