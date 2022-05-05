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
onready var notice_text = $NoticeText

func _ready():
	GlobalSignals.connect("keep_placed", self, "_on_building_keep_placed")

func update_gold_amount(amount):
	gold_label.text = "Gold: %s" % amount

func update_wave(wave):
	wave_label.text = "Wave: %s" % wave

func _on_construction_button_pressed(construction : ConstructionStats):
	emit_signal("construction_selected", construction)
	
	var stats : BuildingStats = construction.stats

	tower_title.text = "%s" % stats.get_type_str()
	tower_price.text = "Cost: %s" % stats.price
	if stats is EconomicBuildingStats:
		tower_description.text = "%s. Generates\n%s Gold per Wave." % [stats.name, stats.gold_production]
	elif stats is DefenseBuildingStats:
		tower_description.text = "%s. Deals %s Damage." % [stats.name, stats.damage]
	else:
		tower_description.text = "%s." % stats.name

func _on_StartWave_pressed():
	emit_signal("wave_started")
	start_wave_button.disabled = true
	start_wave_label.modulate.a = 0.1

func _on_wave_ended():
	start_wave_button.disabled = false
	start_wave_label.modulate.a = 1.0

func _on_building_keep_placed():
	start_wave_button.disabled = false
	$PlaceKeep.queue_free()
	notice_text.text = ""
	start_wave_label.modulate.a = 1.0

func _on_final_boss_killed():
	notice_text.text = "Congulations! You killed the evil sorcerer and his army!"
