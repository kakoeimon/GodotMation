tool
extends Node


var node_type = 0
var type = 7
export(String) var caption
export(String) var color
export(int) var actions
export(int) var activation
export(int) var pull_mode
export(Array, int) var input_resources_indices = []
export(Array, int) var output_resources_indices = []
export(Array, int) var input_states_indices = []
export(Array, int) var output_states_indices = []

var input_resources = []
var output_resources = []
var input_states = []
var output_states = []


func _ready():
	if not Engine.is_editor_hint():
		var parent = get_parent()
		for n in input_resources_indices:
			input_resources.push_back(parent.get_child(n))
		for n in output_resources_indices:
			output_resources.push_back(parent.get_child(n))
		for n in input_states_indices:
			input_states.push_back(parent.get_child(n))
		for n in output_states_indices:
			output_states.push_back(parent.get_child(n))
			

func trigger():
	print("queue trigger is not implemented yet")
	pass