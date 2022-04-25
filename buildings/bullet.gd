extends Area2D


export(float) var speed = 100
var hit_damage = 1
var direction = Vector2()

func _process(delta):
	# Moves the bullet in a specified direction and specifed speed
	position += speed * direction * delta

func _on_Bullet_body_entered(body):
	# Despawns after hiting the enemy
	if body.is_in_group("enemies"):
		body.damage(hit_damage)
		queue_free()

func _on_Lifetime_timeout():
	queue_free()
