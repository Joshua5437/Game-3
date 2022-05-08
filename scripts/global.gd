extends Node

const ENEMY_GROUP = "enemy"
const NEIGHOR_CELLS = [
	Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
	Vector2(-1, 0), Vector2(1, 0),
	Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1)
]

var procedural_generate_map = false


# Returns unique id using cantor pairing function
static func cantor(x, y):
	return (x + y) * (x + y + 1) / 2 + y


# Returns unqiue id using cantor pairing function
static func cantorv(vec : Vector2):
	return (vec.x + vec.y) * (vec.x + vec.y + 1) / 2 + vec.y


# Generates and returns points on a line
# Based on Bresenham's line algorithm
# "https://en.wikipedia.org/wiki/Bresenham's_line_algorithm"
static func plot_line(x0 : int, y0 : int, x1 : int, y1 : int):
	if abs(y1 - y0) < abs(x1 - x0):
		if x0 > x1:
			return plot_line_low(x1, y1, x0, y0)
		else:
			return plot_line_low(x0, y0, x1, y1)
	else:
		if y0 > y1:
			return plot_line_low(x1, y1, x0, y0)
		else:
			return plot_line_low(x0, y0, x1, y1)


static func plot_linev(start : Vector2, end : Vector2):
	#warning-ignore:narrowing_conversion
	#warning-ignore:narrowing_conversion
	#warning-ignore:narrowing_conversion
	#warning-ignore:narrowing_conversion
	return plot_line(start.x, start.y, end.x, end.y)


static func plot_line_low(x0, y0, x1, y1):
	var cells = []
	
	var dx = x1 - x0
	var dy = y1 - y0
	var yi = 1
	
	if dy < 0:
		yi = -1
		dy = -dy
	var D = (2 * dy) - dx
	var y = y0
	
	for x in range(x0, x1):
		cells.append(Vector2(x, y))
		if D > 0:
			y = y + yi
			D = D + (2 * (dy - dx))
		else:
			D = D + 2 * dy
	return cells


static func plot_line_high(x0, y0, x1, y1):
	var cells = []
	
	var dx = x1 - x0
	var dy = y1 - y0
	var xi = 1
	
	if dx < 0:
		xi = -1
		dx = -dx
	var D = (2 * dx) - dy
	var x = x0
	
	for y in range(y0, y1):
		cells.append(Vector2(x, y))
		if D > 0:
			x = x + xi
			D = D + (2 * (dx - dy))
		else:
			D = D + 2 * dx
	return cells