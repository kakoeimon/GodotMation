tool
extends Node

var type = 7
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

####### Extra vars for the functionality of the nodes

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

var interval_i = 0

var resources_line = []

export(bool) var queue = true

var pushed = false

func trigger():
	if not active: return

	for r in input_resources:
		if not r.trigger():
			satisfied = false
	if output_resources.size():
		output_resources[0].trigger()


	
	if satisfied:
		for r in input_resources:
			r.update_flow()
		for s in trigger_states:
			s.end_node.trigger()
	for r in input_resources:
		if not r.satisfied:
			for s in reverse_trigger_states:
				s.end_node.trigger()
			break
	pass


func pull_resources(resource):
	if not active: return
	pushed = true
	if not resource.trigger():
		satisfied = false

	
func apply_satisfaction():
	if output_resources.size():
		output_resources[0].trigger()

	pushed = false

func can_push(value):
	if number > 0:
		for s in trigger_states:
			s.end_node.trigger()
	return number + output_number
	


func change_input_state(value): 
	input_number += value
	#value is and the state change in fact so we trigger the output states with this value
	for s in output_states:
		s.trigger(value)
	return input_number


func change_output_state(value):
	output_number += value
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
	#if output_number or input_number:
	#number += output_number + input_number
	
	#if emit_state_changed: emit_signal("state_changed" , number)
	
	
	if not queue:
		resources_line[interval_i] = number + output_number + input_number
		interval_i +=1
		if interval_i >= resources_line.size(): interval_i = 0
		number = resources_line[interval_i]
	else:
		resources_line[0] += output_number + input_number
		interval_i +=1
		if interval_i >= resources_line.size(): interval_i = 0
		if interval_i == 0 and resources_line[0] > 0:
			number = 1
		else:
			number = 0
			
	output_number = 0
	input_number = 0
		#if queue and number > 1: number = 1
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
	dict.resource_color = resource_color
	dict.caption_pos = caption_pos
	dict.thickness = thickness
	dict.x = position.x
	dict.y = position.y
	dict.queue = queue
	
	return dict