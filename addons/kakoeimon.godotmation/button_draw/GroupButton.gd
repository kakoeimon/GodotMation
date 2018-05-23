tool
extends "BaseButton.gd"



func draw():
	var radius = get_size().x / 2
	draw_set_transform(Vector2(8, 45), 0, Vector2(1.6, 1.6))
	draw_string(get_font(""), Vector2(), "Group", Color(1,1,1))
	pass
