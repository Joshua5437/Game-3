extends Control

export(PackedScene) var return_menu_scene

func _on_Restart_pressed():
	get_tree().change_scene(get_tree().current_scene.filename)

func _on_ReturnMenu_pressed():
	get_tree().change_scene_to(return_menu_scene)
