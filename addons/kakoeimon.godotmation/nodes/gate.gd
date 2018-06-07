tool
extends Node


var type = 3

export(String) var caption

export(int) var color
export(int) var actions
export(int) var activation_mode
export(int) var pull_mode
export(String) var resource_color
export(int) var starting_resources
export(int) var number = 0
export(int) var capacity

export(float) var caption_pos
export(int) var thickness
export(Vector2) var position
export(int) var gate_type


####### Extra vars for the functionality of the pool

var input_resources = []
var output_resources = []
var input_states = []
var output_states = []

var trigger_states = []
var reverse_trigger_states = []
var input_conditional_states = []


export(bool) var active = true
var satisfied = true

var input_number = 0

var output_number = 0

var output_i = 0

var pushed = false

func trigger():
	if not active: return
	
	##################PULL ANY
	if pull_mode != 1: #pull any
		for r in input_resources:
			if not r.trigger():
				satisfied = false
		##################PULL ALL
	elif pull_mode == 1: #pull all
		for r in input_resources:
			if not r.can_push_all():
				satisfied = false
				break
		if satisfied:
			for r in input_resources:
				r.trigger()

	
	if satisfied:
		for r in input_resources:
			r.update_flow()
		for s in trigger_states:
			s.end_node.trigger()
	if gate_type == 0 and output_resources.size():
		var number_type = output_resources[0].object_number_1.get_type()
		if number_type == 0: #number type, see number.gd for more
			while output_resources[output_i].trigger():
				output_resources[output_i].update_flow()
				output_resources[output_i].used = false
				output_i += 1
				if output_i > output_resources.size()-1: output_i = 0
		elif number_type == 1: #percentage
			var random_resource = randi()%100
			var random_position = 0
			for r in output_resources:
				var resource_percentage = r.object_number_1.get_number()
				if  random_resource <= resource_percentage + random_position:
					r.end_node.change_input_state(number)
					break
				random_position += resource_percentage
			number = 0
	for r in input_resources:
		if not r.satisfied:
			for s in reverse_trigger_states:
				s.end_node.trigger()
			break
	pass

func pull_resources(resource):
	pass
	
func apply_satisfaction():
	#print("pushed gates are not implemented, yet")
	pass

func can_push(value):
	if value <= number:
		return value
	return max(0, number)



func change_input_state(value): 
	number += value
	trigger()
	#value is and the state change in fact so we trigger the output states with this value
	for s in output_states:
		s.trigger(value)
	return input_number


func change_output_state(value):
	number += value
	#value is and the state change in fact so we trigger the output states with this value
	for s in output_states:
		s.trigger(value)
	return value


func get_changed_number():
	return number + output_number + input_number

func get_output_number():
	return number + output_number
	
func get_input_number():
	return number + input_number


func apply_state():
	if output_number or input_number:
		number += output_number + input_number
		
		output_number = 0
		input_number = 0
	satisfied = true
	#active is setted here as true and this may change by the input_conditional_states
	active = true
	for s in input_conditional_states:
		s.trigger()

func get_dict():
	var dict = {}
	dict.type = type
	dict.caption = caption
	dict.color = color
	dict.actions = actions
	dict.activation_mode = activation_mode
	dict.pull_mode = pull_mode
	dict.gate_type = gate_type
	dict.resource_color = resource_color
	dict.caption_pos = caption_pos
	dict.thickness = thickness
	dict.x = position.x
	dict.y = position.y
	
	return dict