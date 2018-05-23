tool
extends "editor_connection.gd"

var type = 0


func get_dict():
	var dict = get_base_dict()
	if not dict: return null
	dict.type = type
	return dict
	
func draw_connection_line(from, to, in_color, in_thickness, antialiased = false ):
	draw_line(from, to, in_color, in_thickness, antialiased)
	pass