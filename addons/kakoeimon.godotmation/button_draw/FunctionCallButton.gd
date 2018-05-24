tool
extends "BaseButton.gd"



func draw():
	var size = get_size()
	var b = Vector2(1,1)
	draw_rect(Rect2(b*9, size - b*18), Color(0,0,0) )
	draw_set_transform(size/2, 0, Vector2(1,0.7))
	draw_circle(Vector2(), size.x / 3, Color(1,1,1))

	
	pass