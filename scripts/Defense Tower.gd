extends Sprite

var tower_health = 100
var attack_per_hit = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Defense_Tower_Button_pressed():
	self.visible = !self.visible
