extends Control

signal how_to_play_pressed
signal options_pressed

func _on_PlayButton_pressed():
	get_tree().change_scene("res://mainScene.tscn")

func _on_HowToPlayButton_pressed():
	emit_signal("how_to_play_pressed")

func _on_OptionsButton_pressed():
	emit_signal("options_pressed")

func _on_ExitButton_pressed():
	get_tree().quit()
