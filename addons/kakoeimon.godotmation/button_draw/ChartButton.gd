tool
extends "BaseButton.gd"



func draw():
	var radius = get_size().x / 2
	draw_set_transform(Vector2(8, 45), 0, Vector2(1.8, 1.8))
	draw_string(get_font(""), Vector2(), "Chart", Color(1,1,1))
	pass
