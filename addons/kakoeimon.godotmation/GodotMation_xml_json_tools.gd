#The dict is diff from the xml in this way :
#1 	the name of the xml element is stored at element_name
#2 	all the nodes are stored to nodes array and not under the graph element
static func parse_xml(path):
	var dict = {}
	##### THIS IS to replace html characters from the xml
	#### it will create a tmp.xml to be parsed cause othewise we loose compartibility
	var file = File.new()
	file.open(path, File.READ)
	var xml = file.get_as_text()
	file.close()
	xml = xml.replace("&lt;", "<")
	file.open("tmp.xml", File.WRITE)
	file.store_string(xml)
	file.close()

	######### Now lets Parse
	var parser = XMLParser.new()
	parser.open("tmp.xml")
	parser.read()
	dict = attributes_to_dict(parser)
	dict["nodes"] = []
	parser.read()

	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			if parser.get_node_name() == "point":
				var nodes_length = dict["nodes"].size()
				if not dict["nodes"][nodes_length-1].has("points"): #["points"].push_back(parser.get_node_data())
					dict["nodes"][nodes_length-1]["points"] = []
				var point_dict = attributes_to_dict(parser)
				dict["nodes"][nodes_length-1]["points"].push_back([point_dict.x, point_dict.y])
				#print(dict)
			else:
				dict["nodes"].push_back(attributes_to_dict(parser))
				dict["nodes"][dict["nodes"].size()-1]
				if dict.nodes.back().type == 8: #End Condition
					dict.nodes.back()["signaller"] = false
				elif dict.nodes.back().type == 2: #Pool
					dict.nodes.back()["emit_state_changed"] = false
				#print(parser.get_node_name())
			


	return dict

# Reads the attributes of the current element and return them as a dictionary
static func attributes_to_dict(parser):
	var colors = {"Black": 0, "White": 1, "Red": 2, "DarkGray": 3, "Orange": 4, "Gray": 5, "Yellow": 6,
				"Teal": 7, "Green": 8, "Lime": 9, "Blue": 10, "DarkBlue": 11, "LightBlue": 12,
				"Purple": 13, "Violet": 14, "Gold": 15, "OrangeRed": 16, "DarkRed": 17, "Brown": 18}
				
	var time_modes = {"asynchronous": 0, "synchronous": 1, "turn-based": 2}
	var distributions = {"fixed speed": 0, "instantaneous": 1}
	var activations = {"passive" : 0, "interactive" : 1, "automatic" : 2, "onstart" : 3}
	var pull_modes = {"pull any" : 0, "pull all" : 1, "push any" : 2, "push all" : 3}
	
	var node_types = {"Pool": 2, "Gate": 3, "Source": 4, "Drain": 5, "Converter": 6,
						"Delay": 7, "EndCondition": 8, "Register": 9, "Trader": 10, "ArtificialPlayer": 11}
						
	var connection_types = {"Resource Connection": 0, "State Connection": 1}
	
	var gate_types = {"deterministic": 0, "dice":1, "skill": 2, "multiplayer": 3, "strategy": 4}
	
	var node_name = parser.get_node_name()
	
	var data = {}
	for i in range(parser.get_attribute_count()):
		
		var attr = parser.get_attribute_name(i)
		var val = parser.get_attribute_value(i)
		if attr != "label":
			if attr == "color" or attr == "resourceColor":
				val = colors[val]
			elif attr == "timeMode":
				val = time_modes[val]
			elif attr == "pullMode":
				val = pull_modes[val]
			elif attr == "distributionMode":
				val = distributions[val]
			elif attr == "activationMode":
				val = activations[val]
			elif attr == "gateType":
				val = gate_types[val]
			elif attr == "symbol":
				attr = "type"
				val = node_types[val]
			elif attr == "type":
				val = connection_types[val]
			elif attr == "delayType":
				if val == "normal":
					data["queue"] = false
				else:
					data["queue"] = true
				continue
			elif val.is_valid_integer():
				val = int(val)
			elif val.is_valid_float():
				val = float(val)
			elif val == "true":
				val = true
			elif val == "false":
				val = false
		data[to_snake_case(attr)] = val
	return data

static func load_json(path):
	var dict = {}
	var file = File.new()
	file.open(path, File.READ)
	var json = file.get_as_text()
	file.close()
	return parse_json(json)



static func save_json(dict , filename):
	var file = File.new()
	file.open(filename, File.WRITE)
	file.store_string(to_json(dict))
	file.close()


static func _build_from_dict(base, dict, in_editor = false, owner = false):
	#print("building")
	var nodes_container
	var resource_pck = preload("nodes/resource.tscn")
	var state_pck = preload("nodes/state.tscn")
	var pool_pck = preload("nodes/pool.tscn")
	var gate_pck = preload("nodes/gate.tscn")
	var source_pck = preload("nodes/source.tscn")
	var drain_pck = preload("nodes/drain.tscn")
	var converter_pck = preload("nodes/converter.tscn")
	var delay_pck = preload("nodes/delay.tscn")
	var end_condition_pck = preload("nodes/end_condition.tscn")
	var function_call_pck = preload("nodes/function_call.tscn")
	
	
	if in_editor:
		nodes_container = base.get_node("DrawingArea/Nodes")
		resource_pck = load("res://addons/kakoeimon.godotmation/editor_nodes/editor_resource.tscn")
		state_pck = load("res://addons/kakoeimon.godotmation/editor_nodes/editor_state.tscn")
		pool_pck = load("res://addons/kakoeimon.godotmation/editor_nodes/editor_pool.tscn")
		gate_pck = load("res://addons/kakoeimon.godotmation/editor_nodes/editor_gate.tscn")
		source_pck = load("res://addons/kakoeimon.godotmation/editor_nodes/editor_source.tscn")
		drain_pck = load("res://addons/kakoeimon.godotmation/editor_nodes/editor_drain.tscn")
		converter_pck = load("res://addons/kakoeimon.godotmation/editor_nodes/editor_converter.tscn")
		delay_pck = load("res://addons/kakoeimon.godotmation/editor_nodes/editor_delay.tscn")
		end_condition_pck = load("res://addons/kakoeimon.godotmation/editor_nodes/editor_end_condition.tscn")
		function_call_pck = load("res://addons/kakoeimon.godotmation/editor_nodes/editor_function_call.tscn")
	else:
		nodes_container = base
	
	#File vars
	base.version = dict.version

	#Panel vars
#	if dict.name:
#		if not in_editor: 
#			base.name = dict.name
#		else:
#			base.godotmation_name = dict.name
	base.author = dict.author
	base.time_mode = dict.time_mode
	base.interval = dict.interval
	base.actions = dict.actions
	base.distribution_mode = dict.distribution_mode
	if dict.color_coding: print("Color Coding is not supported by GodotMation.")
	base.dice = dict.dice
	base.skill = dict.skill
	base.multiplayer_skill = dict.multiplayer
	base.strategy = dict.strategy
	base.width = dict.width
	base.height = dict.height

	#Panel RUN vars
	base.number_of_runs = dict.number_of_runs
	base.visible_runs = dict.visible_runs
	base.speed = dict.speed

	var resources = []
	var states = []
	
	for node in dict.nodes:
		if node.type >= 2:
			var child
			match int(node.type):
				2:
					child = pool_pck.instance()
					child.resource_color = node.resource_color
					child.starting_resources = node.starting_resources
					child.number = node.starting_resources
					child.capacity = node.capacity
					child.emit_state_changed = node.emit_state_changed
				3:
					child = gate_pck.instance()
					child.gate_type = node.gate_type
				4:
					child = source_pck.instance()
				5:
					child = drain_pck.instance()
				6:
					child = converter_pck.instance()
				7:
					child = delay_pck.instance()
					child.queue = node.queue
				8:
					child = end_condition_pck.instance()
					child.signaller = node.signaller
				9:
					child = function_call_pck.instance()
				_:
					print("NOT IN MATCH " + str(node.type))

			#THE COMMON NODE VARS
			child.caption = node.caption
			child.caption_pos = node.caption_pos
			
			
			child.actions = node.actions
			child.activation_mode = int(node.activation_mode)
			child.pull_mode = node.pull_mode
			child.color = node.color
			child.thickness = node.thickness

			child.position = Vector2(node.x, node.y)

			nodes_container.add_child(child)
			if child.caption:
				child.name = child.caption
			#child.name = child.name.replace("@","")
			if owner: child.owner = base.owner
			#if owner: child.set_owner(base.get_tree().get_edited_scene_root())


		else:
			var child
			match int(node.type):
				0:
					child = resource_pck.instance()
					if node.has("points"):
						if not child.points: child.points = []
						for p in node.points:
							child.points.append( Vector2(p[0], p[1]) )
				1:
					child = state_pck.instance()
					if node.has("points"):
						if not child.points: child.points = []
						for p in node.points:
							child.points.append( Vector2(p[0], p[1]) )
							
			child.color = node.color
			child.end = node.end
			child.start = node.start
			child.label = node.label
			child.thickness = node.thickness
			nodes_container.add_child(child)
			if in_editor:
				child.get_node("Label").text = child.label
			#child.name = child.name.replace("@","")
			if owner: child.owner = base.owner
			#if owner: child.set_owner(base.get_tree().get_edited_scene_root())
			
		

static func to_snake_case(string):
	var capitals = ["A", "B", "C", "D", "E", "F", "G",
					"H", "I", "J", "K", "L", "M", "N",
					"O", "P", "Q", "R", "S", "T", "U",
					"V", "W", "X", "Y", "Z"]
	
	var string_pos = 0
	var capital_pos = 0
	var found = false
	for i in range(string.length()):
		for j in range(capitals.size()):
			if string[i] == capitals[j]:
				string_pos = i
				capital_pos = j
				found = true
				break
				break
				
	if found:
		var out = string.left(string_pos) + "_" + capitals[capital_pos].to_lower() + string.right(string_pos + 1)
		return to_snake_case(out)
	else:
		return string

