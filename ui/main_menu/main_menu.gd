extends Control

enum State { Main = 0, HowToPlay = 1, Options = 2}
var current_state = State.Main

onready var main_control = $Main
onready var how_to_play_control = $HowToPlay
onready var options_control = $Options

onready var controls = [$Main, $HowToPlay, $Options]

func change_state(state):
	for i in range(len(controls)):
		if state == i:
			controls[i].show()
		else:
			controls[i].hide()
