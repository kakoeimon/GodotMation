tool
extends Node


var type = 4
export(String) var caption
export(int) var color
export(int) var actions
export(int) var activation_mode

export(int) var pull_mode

export(String) var resource_color

export(float) var caption_pos
export(int) var thickness
export(Vector2) var position


var input_resources = []
var output_resources = []
var input_states = []
var output_states = []

var input_conditional_states = []

var active = true

var trigger_states = []

var pushed = false


#Source only triggers the output connection's end nodes to pull resources.
func trigger():
	if not active: return
	
	for r in output_resources:
		r.end_node.pull_resources(r)

	for s in trigger_states:
		s.end_node.trigger()
	return

func pull_resources(resource):
	pass
	
func apply_satisfaction():
	pass


func can_push(value):
	return value


func change_input_state(value): 
	return value

func change_output_state(value):
	return value

func apply_state():
	active = true
	for s in input_conditional_states:
		s.trigger()
	return true
	
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