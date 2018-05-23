tool
extends Node


var type = 8
export(String) var caption
export(int) var color
export(int) var actions
export(int) var activation_mode

export(int) var pull_mode

export(String) var resource_color

export(float) var caption_pos
export(int) var thickness
export(Vector2) var position
export(bool) var signaller = true

#This just exist to get the size that it is zero in the setup in godotmation.gd
var input_resources = [] 

var input_conditional_states = []

var active = false

signal reached_condition

#Source only pushes resources, the push mode does not matter
func trigger():
	pass

func pull_resources(resource):
	return 
	

func push_resources():
	pass



func can_push(value):
	return false


func change_state(value): 
	pass

func apply_state():
	if input_conditional_states.size(): active = true
	for s in input_conditional_states:
		s.trigger()
	if active:
		if not signaller:
			var parent = get_parent()
			if parent.has_node("Timer"):
				var t = parent.get_node("Timer")
				t.disconnect("timeout", parent, "_interval_timeout")
				t.queue_free()
		emit_signal("reached_condition")

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