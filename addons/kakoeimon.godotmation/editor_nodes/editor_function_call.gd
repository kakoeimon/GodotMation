tool
extends "editor_node.gd"

var type = 9

export(int) var resource_color = 0
export(int) var number = 0

var selected = false

onready var colors = get_parent().get_parent().get_parent().colors
onready var font = get_parent().get_parent().get_parent().get_font("")




func draw(in_color, in_radius):
	var size = Vector2(in_radius, in_radius)
	draw_rect(Rect2(-size, size*2), in_color )
	draw_set_transform(Vector2(), 0, Vector2(1,0.7))
	draw_circle(Vector2(), size.x, Color(1,1,1))

	
	
func _draw():
	if selected:
		var size = Vector2(radius, radius)
		draw_rect(Rect2(-size, size*2), get_parent().get_parent().selected_color )
		
	draw(colors[color], radius - thickness)
	
	
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
	
	
func get_dict():
	var dict = get_base_dict()
	dict.type = type
	dict.resource_color = resource_color
	
	return dict
	