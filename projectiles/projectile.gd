extends Area2D
class_name Projectile

const ENEMY_GROUP = "enemy"

export(float) var speed = 200
var damage_amount = 1
var target = Vector2()

func _ready():
	look_at(target)


func setup(p_position : Vector2, p_target : Vector2, p_damage_amount : int):
	position = p_position
	target = p_target
	damage_amount = p_damage_amount


func _process(delta):
	position = position.move_toward(target, speed * delta)
	if position.distance_to(target) < 1:
		queue_free()


func _on_Actor_entered(area:Area2D):
	if area is Actor and not area.is_dead():
		area.take_damage(damage_amount)
		queue_free()
