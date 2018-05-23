tool
extends "BaseButton.gd"



func draw():
	var pos = get_size() / 2
	var radius = pos.x - 15
	draw_circle(pos, radius + 3 , Color(0,0,0))
	draw_circle(pos, radius , Color(1,1,1))
	var _x = 7
	var _y = 13
	draw_line(pos, pos - Vector2(_x, _y),Color(0,0,0), 3)
	draw_line(pos, pos + Vector2(_x, -_y),Color(0,0,0), 3)
	draw_line(pos - Vector2(_x, _y), pos + Vector2(_x, -_y),Color(0,0,0), 3)
	
	draw_line(pos, pos + Vector2(_x, _y),Color(0,0,0), 3)
	draw_line(pos, pos - Vector2(_x, -_y),Color(0,0,0), 3)
	draw_line(pos + Vector2(_x, _y), pos - Vector2(_x, -_y),Color(0,0,0), 3)
	pass
