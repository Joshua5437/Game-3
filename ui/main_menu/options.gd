extends Control

signal go_back

func _on_GoBackButton_pressed():
	emit_signal("go_back")
