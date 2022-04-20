extends Node2D

export(Resource) var stats

func damage(hits):
	stats.health -= hits
	if stats.health <= 0:
		die()

func die():
	queue_free()
