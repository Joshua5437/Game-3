extends Button

signal construction_button_pressed(construction)

export(Resource) var construction

func _ready():
	connect("pressed", self, "_on_button_pressed")

func _on_button_pressed():
	print("construction")
	emit_signal("construction_button_pressed", construction)
