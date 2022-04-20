extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/PlayButton.grab_focus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass




func _on_PlayButton_pressed():
	get_tree().change_scene("res://mainScene.tscn")


func _on_HowToPlayButton_pressed():
	get_tree().change_scene("res://howToPlay.tscn")


func _on_OptionsButton_pressed():
	pass # Replace with function body.


func _on_ExitButton_pressed():
	get_tree().quit()
