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
			dict["nodes"].push_back(attributes_to_dict(parser))

	return dict
	
# Reads the attributes of the current element and return them as a dictionary
static func attributes_to_dict(parser):
	var colors = {"Black": 0, "Brown": 1, "Red": 2, "DarkGray": 3, "Orange": 4, "Gray": 5, "Yellow": 6,
				"Teal": 7, "Green": 8, "Lime": 9, "Blue": 10, "DarkBlue": 11, "LightBlue": 12,
				"Purple": 13, "Violet": 14, "Gold": 15, "OrangeRed": 16, "DarkRed": 17, "White": 18}

	var data = {}
	for i in range(parser.get_attribute_count()):
		var attr = parser.get_attribute_name(i)
		var val = parser.get_attribute_value(i)
		if attr != "label":
			if attr == "color" or attr == "resourceColor":
				val = colors[val]
			elif val.is_valid_integer():
				val = int(val)
			elif val.is_valid_float():
				val = float(val)
			elif val == "true":
				val = true
			elif val == "false":
				val = false
		data[attr] = val
	data.node_type = parser.get_node_name()
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
	
	
static func _build_from_dict(base, dict):
	print("building")
	var time_modes = {"asynchronous": 0, "synchronous": 1, "turn-based": 2}
	var distributions = {"fixed speed": 0, "instantaneous": 1}
	var activations = {"passive" : 0, "interactive" : 1, "automatic" : 2, "onstart" : 3}
	var pull_modes = {"pull any" : 0, "pull all" : 1, "push any" : 2, "push all" : 3}
	#File vars
	#base.version = dict.version
	#base.node_type = dict.node_type
	
	#Panel vars
	if dict.name:
		base.name = dict.name
	#base.author = dict.author
	base.time_mode = time_modes[dict.timeMode]
	base.interval = dict.interval
	base.actions = dict.actions
	base.distribution = distributions[dict.distributionMode]
	base.color_coding = dict.colorCoding
	base.dice = dict.dice
	base.skill = dict.skill
	base.multiplayer = dict.multiplayer
	base.strategy = dict.strategy
	#base.width = dict.width
	#base.height = dict.height
	
	#Panel RUN vars
	#base.number_of_runs = dict.numberOfRuns
	#base.visible_runs = dict.visibleRuns
	#base.speed = dict.speed
	
	##########################################
	
	var resources = [] #this is to keep track of the connections
	var states = []
	for node in dict.nodes:
		#print(node)
		if node.node_type == "node":
			var child
			match node.symbol:
				"ArtificialPlayer":
					child = preload("nodes/artificial_player.tscn").instance()
					child.actions_per_turn = node.actionsPerTurn
				"EndCondition":
					child = preload("nodes/end_condition.tscn").instance()
				"Register":
					child = preload("nodes/register.tscn").instance()
					child._max = node.max
					child._min = node.min
					child.start = node.start
					child.step = node.step
				"Delay":
					if node.delayType == "normal":
						child = preload("nodes/delay.tscn").instance()
					else:
						child = preload("nodes/queue.tscn").instance()
				"Trader":
					child = preload("nodes/trader.tscn").instance()
					child.resource_color = node.resourceColor
				"Converter":
					child = preload("nodes/converter.tscn").instance()
					child.resource_color = node.resourceColor
				"Drain":
					child = preload("nodes/drain.tscn").instance()
				"Source":
					child = preload("nodes/source.tscn").instance()
					child.resource_color = node.resourceColor
				"Gate":
					child = preload("nodes/gate.tscn").instance()
					child.gate_type = node.gateType
				"Pool":
					child = preload("nodes/pool.tscn").instance()
					child.resource_color = node.resourceColor
					child.number = node.startingResources
					child.capacity = node.capacity
				_:
					print("NOT IN MATCH " + node.symbol)
			
			#THE COMMON NODE VARS
			child.caption = node.caption
			if child.caption:
				child.name = child.caption
			child.actions = node.actions
			child.activation = activations[node.activationMode]
			child.pull_mode = pull_modes[node.pullMode]
			child.color = node.color
			base.add_child(child)
			child.name = child.name.replace("@","")
			child.set_owner(base.get_tree().get_edited_scene_root())
			
			
		elif node.node_type == "connection":
			var child
			match node.type:
				"Resource Connection":
					child = preload("nodes/resource.tscn").instance()
					resources.push_back(child)
				"State Connection":
					child = preload("nodes/state.tscn").instance()
					states.push_back(child)
			child.color = node.color
			child.end = node.end
			child.start = node.start
			child.label = node.label
			base.add_child(child)
			child.name = child.name.replace("@","")
			child.set_owner(base.get_tree().get_edited_scene_root())
			
			
	#Add the conections, this is an extra step to make nodes and connections
	#have references of inputs and outputs
	
	for r in resources:
		base.get_child(r.start).output_resources_indices.push_back(r.get_index())
		base.get_child(r.end).input_resources_indices.push_back(r.get_index())
	for s in states:
		print(s.input_resources_indices)
		base.get_child(s.start).output_states_indices.push_back(s.get_index())
		base.get_child(s.end).input_states_indices.push_back(s.get_index())


