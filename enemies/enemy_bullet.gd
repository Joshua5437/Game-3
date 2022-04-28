extends Area2D
class_name EnemyBullet

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(float) var speed = 200
var hit_damage
var direction = Vector2()
var target
#var spent = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += speed * direction * delta
	if (target.destroyed):
		queue_free()

func _damage_tower(building : Node2D):
	if building.is_in_group("buildings") and building.destroyed != true and building == target:
		
		building.damage(hit_damage)
		queue_free()


func _on_EnemyBullet_area_entered(area):
	
	_damage_tower(area)




func _on_EnemyBullet_body_entered(body):
	_damage_tower(body)
