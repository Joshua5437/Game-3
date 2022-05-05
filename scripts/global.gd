extends Node

const ENEMY_GROUP = "enemy"

# Returns unique id using cantor pairing function
func cantor(x, y):
	return (x + y) * (x + y + 1) / 2 + y

# Returns unqiue id using cantor pairing function
func cantorv(vec : Vector2):
	return (vec.x + vec.y) * (vec.x + vec.y + 1) / 2 + vec.y
