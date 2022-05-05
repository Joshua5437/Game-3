extends Area2D
class_name Actor

signal die(area)

export var health = 1
var dead setget , is_dead

func take_damage(amount):
    health -= amount
    if health <= 0:
        emit_signal("die", self)


func is_dead():
    return health <= 0