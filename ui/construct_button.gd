extends Button

signal construction_button_pressed(construction)

export(Resource) var construction
export(AudioStream) var selected_sound

onready var selected_stream = AudioStreamPlayer.new()

func _ready():
	selected_stream.stream = selected_sound
	add_child(selected_stream)
	connect("pressed", self, "_on_button_pressed")

func _on_button_pressed():
	selected_stream.play()
	emit_signal("construction_button_pressed", construction)
