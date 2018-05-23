tool
extends Node

const number = preload("number/number.gd")
const number_tool = preload("number/number_tool.gd")

var type = 0 #RESOURCE
export(int) var color = 0
export(String) var label = "+1"
export(int) var end = 0
export(int) var start = 0

export(Array, int) var input_resources_indices = []
export(Array, int) var output_resources_indices = []
export(Array, int) var input_states_indices = []
export(Array, int) var output_states_indices = []

var input_resources = []
var output_resources = []
var input_states = []
var output_states = []

var start_node
var end_node
export(Array, Vector2) var points
export(int) var resource_type = 0
export(int) var number = 0 
export(int) var thickness
var object_number_1
var object_number_2
var number_resolved = false
var ticks = 0

var active = true
var pushed_resources = 0
var satisfied = true

var used = false

var previous_interval = 0


func trigger():
	if not active or used or not start_node.active or number <=0: return false
	used = true
	
	if resource_type == 0: #this means all
		print("all is not implemented yet")
	var flow = start_node.can_push(number)
	start_node.change_output_state(-flow)
	end_node.change_input_state(flow)
	pushed_resources += flow
	satisfied = flow >= number
	return pushed_resources >= number
	
func check_flow():
	return pushed_resources >= number

func update_flow():
	pushed_resources -= number
	
func can_push_all():
	if not active or used: return false
	if number < 0: return false
	
	return start_node.can_push(number) >= number


func change_input_state(value, state_type = 0):
	if not value: return
	if resource_type == 1: #Flow rate
		object_number_1.add_value(value)


	elif resource_type == 2: #Interval
		if state_type == 0:
			object_number_1.add_value(value)
			ticks = 0 #Just reset it
		elif state_type == 1: #State with label with i
			object_number_2.add_value(value)
		pass
	elif resource_type == 3: #Multiplication
		if state_type == 0:
			object_number_2.add_value(value)
		elif state_type == 2: #State with label with m
			object_number_1.add_value(value)
		pass

func apply_state():
	used = false
	get_number()
	
func set_number(value):
	number = value

func get_number():
	if resource_type == 0: #all
		number = start_node.number
	elif resource_type == 1: #Flow rate
		number = object_number_1.get_value()
	elif resource_type == 2: #Interval
		var parent_ticks = get_parent().ticks
		if parent_ticks >= ticks + previous_interval:
			ticks = parent_ticks
			previous_interval = object_number_2.get_value()
			number = object_number_1.get_value()
		else:
			number = 0
	elif resource_type == 3: #Multiplication
		number = object_number_1.get_value() * object_number_2.get_value()
	return number


func convert_label():
	if not label: label = "1"
	if label == "all":
		resource_type = 0
		return
	var tmp_label = label.split("/")
	if tmp_label.size() > 1:
		resource_type = 2
		object_number_1 = number_tool.from_string(tmp_label[0])
		object_number_2 = number_tool.from_string(tmp_label[1])
		previous_interval = object_number_2.get_value()
	else:
		tmp_label = label.split("*")
		if tmp_label.size() > 1:
			resource_type = 3
			object_number_1 = number_tool.from_string(tmp_label[0])
			object_number_2 = number_tool.from_string(tmp_label[1])
		else:
			if label[0] != "!" and label[0] != "=" and label[0] != ">" and label[0] != "<":
				resource_type = 1
			else:
				resource_type = 4
			object_number_1 = number_tool.from_string(label)
	pass
	
func get_label():
	if resource_type == 0:
		return "all"
	elif resource_type == 1:
		return object_number_1.get_label()
	elif resource_type == 2:
		return object_number_1.get_label() + "/" + object_number_2.get_label()
	elif resource_type == 3:
		return object_number_1.get_label() + "*" + object_number_2.get_label()
	return object_number_1.get_label()
	
	
func get_dict():
	var dict = {}
	dict.type = type
	dict.color = color
	dict.label = label
	dict.end = end
	dict.start = start
	dict.number = number
	dict.thickness = thickness

	dict.points = []
	for p in points:
		dict.points.append([p.x, p.y])
		
	return dict