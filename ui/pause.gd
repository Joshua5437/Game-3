extends Control

const GAME_OVER_TEXT = "Game Over"
const RESTART_GAME_TEXT = "Restart Game"

export(PackedScene) var return_menu_scene
export(ShortCut) var unpause_shortcut

onready var label = $Label
onready var top_button = $Buttons/Top

var top_func_ref = funcref(self, "_unpause_game")
var is_paused = false # Keep seperate variable for tracking pauses

func _ready():
	PlayerData.connect("game_over", self, "_on_game_over")
	top_button.shortcut = unpause_shortcut

func _restart_game():
	get_tree().change_scene(get_tree().current_scene.filename)

func _unpause_game():
	is_paused = false
	get_tree().paused = is_paused
	hide()

func _on_Top_pressed():
	top_func_ref.call_func()

func _on_Bottom_pressed():
	get_tree().change_scene_to(return_menu_scene)
	get_tree().paused = false

func _on_game_over():
	show()
	label.text = GAME_OVER_TEXT
	top_button.text = RESTART_GAME_TEXT
	top_button.shortcut = null
	top_func_ref = funcref(self, "_restart_game")

func _on_paused():
	show()
	is_paused = true


func _on_Options_go_back():
	top_button.shortcut = unpause_shortcut
	$OptionsBG.hide()


func _on_Options_pressed():
	top_button.shortcut = null
	$OptionsBG.show()


func _on_HowToPlay_pressed():
	top_button.shortcut = null
	$HowToPlayBG.show()


func _on_HowToPlay_go_back_pressed():
	top_button.shortcut = unpause_shortcut
	$HowToPlayBG.hide()
