extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.stream.loop = false

func _on_Econ_2_Button_pressed():
	self.visible = !self.visible
	$AudioStreamPlayer.play()
