tool
extends Node


######## For The tool
export(String, FILE, "*.xml") var xml = null setget _load_from_xml
export(String, FILE, "*.json") var json = null setget _load_from_json


export(int) var time_mode
export(float) var interval
export(int) var actions
export(int) var distribution
export(int) var color_coding
export(String) var dice = "D6"
export(String) var skill
export(String) var multiplayer
export(String) var strategy

export(Array, int) var interactive_nodes_indices
export(Array, int) var automatic_nodes_indices
export(Array, int) var starting_nodes_indices
export(Array, int) var states_indices

var nodes = [] #All the nodes, no connections. This is for state change
var interactive_nodes = []
var automatic_nodes = []
var on_start_nodes = []

var resources = []
var states = []

var trige

var ticks = 0 #This is to count the ticks for the interval resources and more...


func _setup():
	for node in get_children():
		if node.type >= 2: #This means that it is a node
			if node.activation_mode == 1:
				interactive_nodes.append(node)
			if node.activation_mode == 2:
				automatic_nodes.append(node)
			if node.activation_mode == 3:
				on_start_nodes.append(node)
			nodes.push_back(node)
		elif node.type == 0:
			node.convert_label()
			resources.append(node)
		elif node.type == 1:
			node.convert_label()
			
			states.append(node)
			pass
	
	
	
	if automatic_nodes.size(): #This is here cause I cannot set it in the edittor
		var t = Timer.new()
		t.name = "Timer"
		add_child(t)
		t.wait_time = interval
		t.connect("timeout", self, "_interval_timeout")
		t.start()
	if starting_nodes_indices.size():
		for i in starting_nodes_indices:
			get_child(i).trigger()

func _ready():
	if not Engine.is_editor_hint():
		#_setup()
		pass

				
			



func _interval_timeout():
	
	ticks +=1
	for n in automatic_nodes:
		n.trigger()
	

	

