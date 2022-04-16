extends Node2D
# TODOs:
# - Needs to shoot at enemies if they are in range
# - Needs stats (look at custom resources on Godot documentation if you want to implement this
# way, but you do not have to if you have a better idea)
# - Needs better texture
# - Need to look at how Godot scene are inherited

func _on_Range_area_entered(area):
	# Used to check other areas (mostly towers and enemies)
	# Note: Please look at the documentation for Area2D to get overlapping areas
	print(area)
