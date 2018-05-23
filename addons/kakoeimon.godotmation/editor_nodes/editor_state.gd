tool
extends "editor_connection.gd"

var type = 1


func _ready():
	pass
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func get_dict():
	var dict = get_base_dict()
	if not dict: return null
	dict.type = type
	return dict

func draw_connection_line(from, to, in_color, in_thickness, antialiased = false):
	var dash = 10
	var line = to - from
	var dist = line.length()
	line = line.normalized()
	var pointer = from
	while (to - pointer).length() > dash*2:
		draw_line(pointer, pointer + line * dash, in_color, in_thickness)
		pointer += line*2*dash
	draw_line(pointer, to, in_color, in_thickness)