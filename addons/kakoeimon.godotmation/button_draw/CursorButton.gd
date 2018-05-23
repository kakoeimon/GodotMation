tool
extends "BaseButton.gd"



func draw():
	var line = []
	line.append(Vector2(24, 11))
	line.append(Vector2(55, 32))
	line.append(Vector2(45, 38))
	line.append(Vector2(57, 58))
	line.append(Vector2(47, 64))
	line.append(Vector2(35, 43))
	line.append(Vector2(24, 49))
	draw_colored_polygon(PoolVector2Array(line), Color(0,0,0))
	
	line = []
	line.append(Vector2(26, 15))
	line.append(Vector2(51, 32))
	line.append(Vector2(41.5, 37.5))
	line.append(Vector2(54, 57))
	line.append(Vector2(47.5, 61))
	line.append(Vector2(36, 41))
	line.append(Vector2(26, 46))
	draw_colored_polygon(PoolVector2Array(line), Color(1,1,1))
	pass
