tool
extends "BaseButton.gd"



func draw():
	var pos = get_size() / 2
	var radius = pos.x - 15
	draw_circle(pos, radius + 3 , Color(0,0,0))
	draw_circle(pos, radius , Color(1,1,1))
	pass
