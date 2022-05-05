extends Control

signal wave_started
signal construction_selected(construction_stats)

onready var gold_label = $TopPanel/CenterContainer/Gold
onready var wave_label = $TopPanel/Wave

onready var tower_title = $TowerInfo/Title
onready var tower_price = $TowerInfo/Price
onready var tower_description = $TowerInfo/Description

onready var start_wave_button = $MarginContainer/StartWave
onready var start_wave_label = $MarginContainer/StartWave/Label
onready var keep_construction_button = $Buildings/GridContainer/Tower
onready var notice_text = $NoticeText

func _ready():
	GlobalSignals.connect("keep_placed", self, "_on_building_keep_placed")

func update_gold_amount(amount):
	gold_label.text = "Gold: %s" % amount

func update_wave(wave):
	wave_label.text = "Wave: %s" % wave

func _on_construction_button_pressed(stats):
	emit_signal("construction_selected", stats)
	var type = stats.get_type()
	tower_title.text = "%s" % type
	tower_price.text = "Cost: %s" % stats.get_price()
	if type == "Economic":
		tower_description.text = "%s Tower. Generates\n%s Gold per Wave." % [stats.get_name(), stats.get_gold()]
	else:
		tower_description.text = "%s Tower. Deals %s Damage." % [stats.get_name(), stats.get_damage()]

func _on_StartWave_pressed():
	emit_signal("wave_started")
	start_wave_button.disabled = true
	start_wave_label.modulate.a = 0.1

func _on_wave_ended():
	start_wave_button.disabled = false
	start_wave_label.modulate.a = 1.0

func _on_building_keep_placed():
	keep_construction_button.disabled = true
	start_wave_button.disabled = false
	$PlaceKeep.queue_free()
	notice_text.text = ""
	start_wave_label.modulate.a = 1.0

func _on_final_boss_killed():
	notice_text.text = "Congulations! You killed the evil sorcerer and his army!"
