extends Area2D

export(float) var speed = 200
var hit_damage = 2
var target = Vector2()

func _ready():
	look_at(target)

func _process(delta):
	position = position.move_toward(target, speed * delta)
	if position.distance_to(target) < 1:
		queue_free()

func _damage_enemy(enemy : Node2D):
	if enemy.is_in_group("enemies"):
		enemy.damage(hit_damage)
		queue_free()

func _on_FireSpell_area_entered(area):
	if not area.is_in_group("enemies"):
		return
	
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("enemies"):
			print("hit")
			area.damage(hit_damage)
	queue_free()
