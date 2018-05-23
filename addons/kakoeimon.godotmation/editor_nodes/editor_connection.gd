tool
extends Node2D

var node_type = 1

const ZERO2D = Vector2()
export(int) var start
export(int) var end
export(String) var label = "+1"
export(float) var label_position
export(int) var color
export(int) var thickness = 2.0
var points = []
var point_radius = 5
var start_node
var end_node

var radius = 15 #This is used for selection
var selected = false

onready var colors = get_parent().get_parent().get_parent().colors
onready var font = get_parent().get_parent().get_parent().get_font("")

class connection_point_class:
	var position = Vector2()
	var radius = 0 #To set after creation by using font var
	var index
	var user
	

	
	func get_index():
		return user.get_index()
	
	func get_dict():
		return user.get_dict()

var connection_point = connection_point_class.new()

func _ready():
	connection_point.user = self
	connection_point.radius = font.get_height()


func update():
	.update()
	get_connection_point()
	
func to_select(pos):
	if points and points.size():
		var p_size = points.size()
		if line_to_point_distance(start_node.position, points[0], pos) <= radius:
			return true
		for i in range(1, p_size):
			if line_to_point_distance(points[i-1], points[i], pos) <= radius:
				return true
		if line_to_point_distance(points.back(), end_node.position, pos) <= radius:
			return true
		pass
	else:
		if line_to_point_distance(start_node.position, end_node.position, pos) <= radius:
			return true
	return false


func draw_arrow(p1, p2, in_color = colors[color], in_thickness = thickness, length = 20):
	var angle = 0.3
	var e0 = (p1 - p2).normalized() * length

	
	draw_line(p2, p2 + e0.rotated(angle), in_color, in_thickness)
	draw_line(p2, p2 + e0.rotated(-angle), in_color, in_thickness)


func get_closest_point(point): #-1 for start_node, -2 for end_node, the rest are index of points array
	var c = -1
	var dist = (start_node.position - point).length()
	if points:
		for i in range(points.size()):
			var d = (points[i] - point).length()
			if d < dist:
				c = i
				dist = d
	var d = (end_node.position - point).length()
	if d < dist:
		c = -2
	return c
	
	

func line_to_point_distance(line_point_1, line_point_2, point):
	var x = point.x
	var y = point.y
	var x1 = line_point_1.x
	var y1 = line_point_1.y
	var x2 = line_point_2.x
	var y2 = line_point_2.y
	
	var A = x - x1;
	var B = y - y1;
	var C = x2 - x1;
	var D = y2 - y1;
	
	var dot = A * C + B * D;
	var len_sq = C * C + D * D;
	var param = -1;
	if (len_sq != 0):
		param = dot / len_sq;

	var xx
	var yy

	if (param < 0):
		xx = x1
		yy = y1
	elif (param > 1):
		xx = x2
		yy = y2
	else:
		xx = x1 + param * C
		yy = y1 + param * D
	
	var dx = x - xx
	var dy = y - yy
	return sqrt(dx * dx + dy * dy)
	
	

func get_base_dict():
	if not is_functional(): return null
	var dict = {}
	dict.node_type = 1
	dict.start = start_node.get_index()
	dict.end = end_node.get_index()
	dict.label = label
	dict.label_position = label_position
	dict.color = color
	dict.thickness = thickness
	dict.points = []
	if points:
		for p in points:
			dict.points.append([p.x, p.y])
	return dict
	
	
func _draw():
	if not start_node and get_parent().get_child_count() >= start +1:
		start_node = get_parent().get_child(start)
		if start_node.type <= 1:
			start_node = start_node.get_connection_point()
		
	if not end_node and get_parent().get_child_count() >= end +1:
		end_node = get_parent().get_child(end)
		if end_node.type <= 1:
			end_node = end_node.get_connection_point()
	
	if selected: draw(get_parent().get_parent().selected_color, thickness*2)
	draw()
	
			
func draw(in_color = colors[color], in_thickness = thickness):
	if start_node and end_node:
		if points and points.size():
			var p_size = points.size()
			var p1 = (points[0] - start_node.position).normalized() * (start_node.radius + point_radius)
			draw_connection_line(start_node.position + p1, points[0], in_color, in_thickness)
			draw_circle(start_node.position + p1, point_radius + in_thickness, in_color)
			draw_circle(points[0], point_radius + in_thickness, in_color)
			for i in range(1, p_size):
				draw_connection_line(points[i-1], points[i], in_color, in_thickness)
				draw_circle(points[i], point_radius + in_thickness, in_color)
			p1 = (points.back() - end_node.position).normalized() * (start_node.radius + point_radius*2)
			var p2 = (points.back() - end_node.position).normalized() * (end_node.radius + point_radius*2)
			draw_connection_line(points.back(), end_node.position + p2, in_color, in_thickness)
			draw_arrow(points[p_size - 1], end_node.position + p2, in_color, in_thickness)
			var p3 = (points.back() - end_node.position).normalized() * (end_node.radius + point_radius)
			draw_circle(end_node.position + p3, point_radius + in_thickness, in_color)
		else:
			var p1 = (start_node.position - end_node.position).normalized() * (start_node.radius + point_radius)
			var p2 = (start_node.position - end_node.position).normalized() * (end_node.radius + point_radius*2)
			draw_connection_line(start_node.position - p1, end_node.position + p2, in_color, in_thickness, false)
			draw_circle(start_node.position - p1, point_radius + in_thickness, in_color)
			draw_arrow(start_node.position, end_node.position + p2, in_color, in_thickness)
			var p3 = (start_node.position - end_node.position).normalized() * (end_node.radius + point_radius)
			draw_circle(end_node.position + p3, point_radius + in_thickness, in_color)
		
		draw_label()
func draw_connection_line(from, to, in_color, in_thickness, antialiased = false ):
	pass
	

func draw_label():
	var point = get_connection_point().position
	$Label.rect_position = point - $Label.rect_size/2
	#draw_string(font, mid, label, colors[color])
	
func get_connection_point():
	if not start_node or not end_node: return
	var total_length = 0
	if points.size():
		total_length += (points[0] - start_node.position).length()
		for i in range(points.size() - 1):
			total_length += (points[i + 1] - points[i]).length()
		total_length += (end_node.position - points.back()).length()
		total_length /=2
		var point_length = (points[0] - start_node.position).length()
		if point_length >= total_length:
			connection_point.position = start_node.position + (points[0] - start_node.position).normalized() * total_length
			return connection_point
			
		var pre_point_length = point_length


		for i in range(points.size() - 1):
			point_length += (points[i + 1] - points[i]).length()
			if point_length >= total_length:
				connection_point.position = points[i] + (points[i + 1] - points[i]).normalized() * (total_length - pre_point_length)
				return connection_point
			pre_point_length = point_length
		point_length += (end_node.position - points.back()).length()
		if point_length >= total_length:
			connection_point.position = points.back() + (end_node.position - points.back()).normalized() * (total_length - pre_point_length)
			return connection_point
	else:
		total_length = (end_node.position - start_node.position).length()
		connection_point.position = start_node.position + (end_node.position - start_node.position).normalized() * total_length / 2
	return connection_point
	pass
	
func get_start_end_sameness():
	if is_start_node_dict() or is_end_node_dict():
		return false
	else:
		return start_node == end_node
	
func is_start_node_dict():
	return typeof(start_node) == TYPE_DICTIONARY
	
func is_end_node_dict():
	return typeof(end_node) == TYPE_DICTIONARY
	
func is_functional():
	return not is_start_node_dict() and not is_end_node_dict()