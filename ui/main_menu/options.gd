extends Control

signal go_back

const SETTINGS_PATH = "user://settings.cfg"

onready var config = ConfigFile.new()
onready var fullscreen_checkbox = $Container/FullscreenCheckBox
onready var master_volume = $Container/MasterVolume/HSlider
onready var effects_volume = $Container/EffectsVolume/HSlider
onready var music_volume = $Container/MusicVolume/HSlider

func _ready():
	load_config()

func _exit_tree():
	config.save(SETTINGS_PATH)

func load_config():
	var err = config.load(SETTINGS_PATH)
	var fullscreen = config.get_value("Display", "fullscreen", false)
	var master_volume_value = config.get_value("Audio", "master", 0.0)
	var effects_volume_value = config.get_value("Audio", "effects", 0.0)
	var music_volume_value = config.get_value("Audio", "music", 0.0)
	
	OS.window_fullscreen = fullscreen
	fullscreen_checkbox.pressed = fullscreen
	
	master_volume.value = master_volume_value
	effects_volume.value = effects_volume_value
	music_volume.value = music_volume_value
	
	var master_bus_index = AudioServer.get_bus_index("Master")
	var effects_bus_index = AudioServer.get_bus_index("Effects")
	var music_bus_index = AudioServer.get_bus_index("Music")
	
	AudioServer.set_bus_volume_db(master_bus_index, master_volume_value)
	AudioServer.set_bus_volume_db(effects_bus_index, effects_volume_value)
	AudioServer.set_bus_volume_db(music_bus_index, music_volume_value)
	
	return err

func _on_GoBackButton_pressed():
	emit_signal("go_back")


func _on_FullscreenCheckBox_toggled(button_pressed):
	config.set_value("Display", "fullscreen", button_pressed)
	OS.window_fullscreen = button_pressed


func _on_Volume_value_changed(value : float, bus_name : String):
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, value)
	config.set_value("Audio", bus_name.to_lower(), value)
