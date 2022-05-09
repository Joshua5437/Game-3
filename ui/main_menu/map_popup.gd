extends Control

func popup():
	$Popup.popup()


func _on_DesignMap_pressed():
	get_tree().change_scene("res://mainScene.tscn")


func _on_ProceduralMap_pressed():
	get_tree().change_scene("res://procedural_scene.tscn")


func _on_Popup_popup_hide():
	hide()
