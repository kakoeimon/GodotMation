tool
extends "BaseButton.gd"



func draw():
	var size = get_size()
	var b = Vector2(1,1)
	draw_rect(Rect2(b*9, size - b*18), Color(0,0,0) )
	draw_rect(Rect2(b*12, size - b*24), Color(1,1,1) )
	draw_rect(Rect2(b*22, size - b*44), Color(0,0,0) )
	
	pass
