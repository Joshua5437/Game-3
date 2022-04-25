extends Control

signal go_back

const SETTINGS_PATH = "user://settings.cfg"

onready var config = ConfigFile.new()
onready var fullscreen_checkbox = $Container/FullscreenCheckBox

func _ready():
	load_config()

func _exit_tree():
	config.save(SETTINGS_PATH)

func load_config():
	var err = config.load(SETTINGS_PATH)
	var fullscreen = config.get_value("Display", "fullscreen", false)
	
	OS.window_fullscreen = fullscreen
	fullscreen_checkbox.pressed = fullscreen
	
	return err

func _on_GoBackButton_pressed():
	emit_signal("go_back")

func _on_FullscreenCheckBox_toggled(button_pressed):
	config.set_value("Display", "fullscreen", button_pressed)
	OS.window_fullscreen = button_pressed
