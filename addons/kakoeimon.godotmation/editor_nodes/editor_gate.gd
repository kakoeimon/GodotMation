tool
extends "editor_node.gd"

var type = 3

export(int) var resource_color = 0
export(int) var starting_resources = 0
export(int) var number = 0
export(int) var capacity = -1
export(int) var gate_type = 0

var selected = false

onready var colors = get_parent().get_parent().get_parent().colors
onready var font = get_parent().get_parent().get_parent().get_font("")



func draw(in_color, in_thickness):
	var line = []
	line.append(Vector2(-radius - in_thickness*2, 0) )
	line.append(Vector2(0, -radius -in_thickness*2) )
	line.append(Vector2(radius + in_thickness*2, 0) )
	line.append(Vector2(0, radius + in_thickness*2) )
	
	draw_colored_polygon(PoolVector2Array(line), in_color)
func _draw():
	if selected:
		draw(get_parent().get_parent().selected_color, thickness)
	
	draw(colors[color], 0)
	draw(colors[1], -thickness)
	var pos = Vector2(radius + thickness, radius + thickness)
	if pull_mode >=2:
		var next = draw_char(font, pos, "p", "&", colors[color])
		pos.x += next
	if pull_mode == 1 or pull_mode == 3:
		draw_string(font, pos,  "&", colors[color])
	
	pos.y = -pos.y
	if activation_mode == 1:
		pass
	elif activation_mode == 2:
		draw_string(font, Vector2(),  "*", colors[color])
	
func set_starting_resources(value):
	starting_resources = value
	$Number.text = str(starting_resources)
	
func get_dict():
	var dict = get_base_dict()
	dict.type = type
	dict.resource_color = resource_color
	dict.gate_type = gate_type
	return dict
	