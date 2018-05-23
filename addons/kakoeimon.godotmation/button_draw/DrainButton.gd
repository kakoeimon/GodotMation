tool
extends "BaseButton.gd"



func draw():
	var radius = get_size().x / 2
	var gap =10
	var line = []
	line.append(Vector2(radius, radius*2 - gap) )
	line.append(Vector2(gap, gap) )
	line.append(Vector2(radius*2 - gap, gap) )

	draw_colored_polygon(PoolVector2Array(line), Color(0,0,0))
	gap +=6
	line = []
	
	line.append(Vector2(radius, radius*2 - gap) )
	line.append(Vector2(gap, gap - 3) )
	line.append(Vector2(radius*2 - gap, gap - 3) )
	draw_colored_polygon(PoolVector2Array(line), Color(1,1,1))
	pass