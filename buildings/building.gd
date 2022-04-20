extends Node2D

export(Resource) var stats

var destroyed = false

func damage(hits):
	stats.health -= hits
	if stats.health <= 0:
		die()

func die():
	destroyed = true
	$Sprite.modulate = Color.red
	#queue_free()

func rebuild():
	destroyed = false
	$Sprite.modulate = Color.white
	
