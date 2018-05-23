tool
extends "BaseButton.gd"



func draw():
	var radius = get_size().x / 2
	var gap =10
	var line = []
	line.append(Vector2(gap, gap) )
	line.append(Vector2(radius*2 - gap, radius) )
	line.append(Vector2(gap, radius*2 - gap) )

	draw_colored_polygon(PoolVector2Array(line), Color(0,0,0))
	gap +=6
	line = []
	
	line.append(Vector2(gap - 3, gap) )
	line.append(Vector2(radius*2 - gap, radius) )
	line.append(Vector2(gap - 3, radius*2 - gap) )
	draw_colored_polygon(PoolVector2Array(line), Color(1,1,1))
	draw_line(Vector2(radius,gap), Vector2(radius, radius*2 - gap), Color(0,0,0), 2.5)
	pass