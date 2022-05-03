extends Node

var _sfx = {}

func _ready():
	var children = get_children()
	for child in children:
		_sfx[child.name] = child

func play_sfx(sfx_name):
	_sfx[sfx_name].play()
