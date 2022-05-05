extends Area2D
class_name Projectile

export(float) var speed = 200
export(int) var hit_damage = 1
var target = Vector2()

func _ready():
	look_at(target)


func setup(p_position : Vector2, p_target : Vector2, p_hit_damage : int):
	position = p_position
	target = p_target
	hit_damage = p_hit_damage


func _process(delta):
	position = position.move_toward(target, speed * delta)
	if position.distance_to(target) < 1:
		queue_free()


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
