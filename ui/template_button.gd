extends Button
class_name TemplateButton

func _ready():
	connect("pressed", self, "_on_pressed")
	connect("mouse_entered", self, "_on_mouse_entered")


func _on_pressed():
	Sound.play_sfx("button_click")

func _on_mouse_entered():
	Sound.play_sfx("button_hover")
