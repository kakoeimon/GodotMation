tool
extends "BaseButton.gd"



func draw():
	var radius = get_size().x / 2
	var gap =10
	var line = []
	draw_line(Vector2(gap, radius), Vector2(gap*2, radius), Color(0,0,0), 3)
	draw_line(Vector2(gap*3, radius), Vector2(gap*4, radius), Color(0,0,0), 3)
	draw_line(Vector2(gap*5, radius), Vector2(radius*2 - gap, radius), Color(0,0,0), 3)
	
	draw_line(Vector2(radius*2 - gap - 1, radius), Vector2(radius*2 - gap*2, radius-gap), Color(0,0,0), 3)
	draw_line(Vector2(radius*2 - gap - 1, radius), Vector2(radius*2 - gap*2, radius+gap), Color(0,0,0), 3)
	pass
