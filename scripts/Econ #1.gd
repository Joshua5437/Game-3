extends Sprite

var tower_health = 100
var gold_per_turn = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Econ_1_Button_pressed():
	self.visible = !self.visible
