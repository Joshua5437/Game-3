extends Sprite

var tower_health = 100
var gold_per_turn = 50

func _ready():
	pass # Replace with function body.

func _on_Econ_2_Button_pressed():
	self.visible = !self.visible
