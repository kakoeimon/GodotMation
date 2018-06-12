tool
extends Node


var type = 9

export(String) var caption
export(int) var color
export(int) var actions
export(int) var activation_mode
export(int) var pull_mode
export(String) var resource_color
export(int) var number = 0
export(float) var caption_pos
export(int) var thickness
export(Vector2) var position

####### Extra vars for the functionality of the pool

var input_resources = []
var output_resources = []
var input_states = []
var output_states = []

var trigger_states = []
var reverse_trigger_states = []
var input_conditional_states = []


export(bool) var active = true

var pushed = false


func trigger():
	if not active or not caption: return
	number = get_parent().call(caption)
	pass


func pull_resources(resource):
	pass

	
func apply_satisfaction():
	pushed = false
	pass

func can_push(value):
	if value <= number:
		return value
	return max(0, number)


func change_input_state(value): 
	return 0


func change_output_state(value):
	if value > number:
		print(value)
	number += value
	return value


func get_changed_number():
	return number

func get_output_number():
	return number
	
func get_input_number():
	return number


func apply_state():
	active = true
	for s in input_conditional_states:
		s.trigger()
	if active:
		trigger()
	else:
		number = 0

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
	
	return dict