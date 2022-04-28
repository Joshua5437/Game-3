extends Area2D


export(float) var speed = 200
var hit_damage = 1
var direction = Vector2()


func _process(delta):
	# Moves the bullet in a specified direction and specifed speed
	position += speed * direction * delta
	

func _damage_enemy(enemy : Node2D):
	if enemy.is_in_group("enemies"):
		enemy.damage(hit_damage)
		queue_free()

func _on_Bullet_body_entered(body):
	_damage_enemy(body)

func _on_Lifetime_timeout():
	queue_free()

func _on_Bullet_area_entered(area):
	_damage_enemy(area)
