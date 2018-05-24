tool
extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var thickness = 2
var playing = false


onready var nodes_container = get_node("Nodes")
onready var buttons = get_node("../Panel/DrawPanel/GridContainer")


#button can be 0 for nothing, 1 for pool, 2 for resource, 3 for state
var button_type = -1
var selected = null
var highlight_node = null
var selected_color = Color(1,1,0)
var button_down = false
var button_2_down = false
var button_2_position = Vector2()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func set_selected(node = null):
	if selected: 
		selected.selected = false
		selected.update()
	
	selected = node
	if node:
		selected.selected = true
		selected.update()
		get_parent()._set_node_tab(selected)
		get_parent().get_node("Panel/Main").hide()
		set_highlight_node()
	else:
		get_parent().get_node("Panel/Main").show()
		get_parent().get_node("Panel/Nodes").hide()
		get_parent().get_node("Panel/Connections").hide()

	
func set_highlight_node(node = null):
	if highlight_node: 
		highlight_node.selected = false
		highlight_node.update()
	
	highlight_node = node
	if node:
		highlight_node.selected = true
		highlight_node.update()
		

func to_drawing_point(point):
	point -= nodes_container.position
	point /= nodes_container.scale
	return point

func _on_DrawingArea_gui_input(event):
	######## PANING AND ZOOMING
	if event is InputEventMouseButton:
		if event.button_index == 2:
			button_2_down = event.pressed
			return
		if event.button_index == 4:
			if nodes_container.scale.x < 1.0 and event.pressed:
				var pos_1 = to_drawing_point(event.position)
				nodes_container.scale += Vector2(0.1, 0.1)
				var pos_2 = to_drawing_point(event.position)
				nodes_container.position += (pos_2 - pos_1) * nodes_container.scale
			return
		if event.button_index == 5 and event.pressed:
			if nodes_container.scale.x > 0.2:
				var pos_1 = to_drawing_point(event.position)
				nodes_container.scale -= Vector2(0.1, 0.1)
				var pos_2 = to_drawing_point(event.position)
				nodes_container.position += (pos_2 - pos_1) * nodes_container.scale
				pass
			return
			
			
	if event is InputEventMouseMotion:
		if button_2_down:
			nodes_container.position += event.relative
			return
	
	################## STORE EVENT POSITION
	var event_position
	if event is InputEventMouseButton or event is InputEventMouseMotion:
	 	event_position = to_drawing_point(event.position)
	
	############ PLAYING THE DIAGRAM
	if playing:
		if event is InputEventMouseButton and event.button_index == 1 and not event.is_echo() and event.pressed:
			for n in nodes_container.get_children():
				if n.type >=2 and n.activation_mode == 1:
					var parent_name = get_parent().name
					var node_name = n.name
					get_parent().get_node("play_godotmation").get_node(parent_name).get_child(n.get_index()).trigger()
		return
	
	############ DRAWING THE DIAGRAM
	
	
	########## CURSOR BUTTON
	if button_type == -1:
		if event is InputEventMouseButton:
			
			button_down = event.pressed
			if not event.is_echo() and button_down:
				set_selected(_catch_node(event_position))
				if selected: button_down = true
			
			if not button_down and selected and selected.type <=1:
				if typeof(selected.start_node) == TYPE_DICTIONARY:
					for node in nodes_container.get_children():
						if node.type >= 2:
							if node.to_select(selected.start_node.position):
								selected.start_node = node
								break
				if typeof(selected.end_node) == TYPE_DICTIONARY:
					for node in nodes_container.get_children():
						if node.type >=2 and node != selected:
							if node.to_select(selected.end_node.position):
								selected.end_node = node
								update_nodes()
								break
				if typeof(selected.end_node) == TYPE_DICTIONARY:
					for node in nodes_container.get_children():
						if selected.type == 1 and node.type <=1 and node != selected:
							if node.to_select(event_position):
								selected.end_node = node.get_connection_point()
								update_nodes()
								break
							
					
				if selected and selected.get_start_end_sameness(): 
					_on_Delete_Button_pressed()
					update_nodes()


		if selected and button_down and event is InputEventMouseMotion:
			if selected.type >=2:
				selected.position = event_position
				update_nodes()
			else:
				var point = selected.get_closest_point(event_position)
				if point >=0:
					selected.points[point] = event_position
				elif point == -1:
					selected.start_node = {"position": event_position, "radius": 0}
				elif point == -2:
					selected.end_node = {"position": event_position, "radius": 0}
				
				update_nodes()
	elif button_type == 0 or button_type == 1:
		if event is InputEventMouseButton:
			button_down = event.pressed
			if not event.is_echo() and button_down:
				if selected and selected.type >=2: set_selected()
				if not selected or typeof(selected.end_node) != TYPE_DICTIONARY:
					for node in nodes_container.get_children():
						if node.type >=2:
							if node.to_select(event_position):
								var new_line
								if button_type == 0:
								 	new_line = preload("editor_nodes/editor_resource.tscn").instance()
								else:
									new_line = preload("editor_nodes/editor_state.tscn").instance()
								new_line.points = []
								new_line.start_node = node
								new_line.end_node = {"position": event_position, "radius": 0}
								new_line.color = get_parent().selected_color
								new_line.thickness = 2.0
								nodes_container.add_child(new_line)
								set_selected(new_line)
								break
				else:
					if typeof(selected.end_node) == TYPE_DICTIONARY:
						
						for node in nodes_container.get_children():
							if node.type >=2 and node != selected:
								if node.to_select(event_position):
									selected.end_node = node
									if selected.get_start_end_sameness(): _on_Delete_Button_pressed()
									update_nodes()
									return
						for node in nodes_container.get_children():
							if selected.type == 1 and node.type <=1 and node != selected:
								if node.to_select(event_position):
									selected.end_node = node.get_connection_point()
									update_nodes()
									return
									
						selected.points.append(selected.end_node.position)
						selected.end_node = {"position": event_position, "radius": 0}
							
					
		if event is InputEventMouseMotion:
			
			if selected and selected.type <= 1 and typeof(selected.end_node) == TYPE_DICTIONARY:
				selected.end_node = {"position": event_position, "radius": 0}
				if selected and selected.get_start_end_sameness(): _on_Delete_Button_pressed()
				update_nodes()
			
			
	if button_type >= 2:
		if event is InputEventMouseButton:
			button_down = event.pressed
			if not event.is_echo() and button_down:
				var catched = _catch_node(event_position)
				if catched:
					_on_CursorButton_pressed()
					set_selected(catched)
				else:
					var node
					if button_type == 2:
						node = preload("editor_nodes/editor_pool.tscn").instance()
					elif button_type == 3:
						node = preload("editor_nodes/editor_gate.tscn").instance()
					elif button_type == 4:
						node = preload("editor_nodes/editor_source.tscn").instance()
					elif button_type == 5:
						node = preload("editor_nodes/editor_drain.tscn").instance()
					elif button_type == 6:
						node = preload("editor_nodes/editor_converter.tscn").instance()
					elif button_type == 7:
						node = preload("editor_nodes/editor_end_condition.tscn").instance()
					elif button_type == 8:
						node = preload("editor_nodes/editor_delay.tscn").instance()
					elif button_type == 9:
						node = preload("editor_nodes/editor_function_call.tscn").instance()
					
					node.position = event_position
					nodes_container.add_child(node)
					set_selected(node)
			
					
	#update_nodes()
	pass

func _catch_node(pos):
	for node in nodes_container.get_children():
		if node.type >= 2:
			if node.to_select(pos):
				return node
	for node in nodes_container.get_children():
		if node.type <= 1:
			if node.to_select(pos):
				return node
	return null

func update_nodes():
	for node in nodes_container.get_children():
		node.update()
	#print("redrawing")
	
		

func _on_StateButton_pressed():
	for b in buttons.get_children():
		if b.name != "StateButton":
			b.pressed = false
		else:
			if b.pressed:
				button_type = 1
			else:
				button_type = -1
				


func _on_CursorButton_pressed():
	if selected and selected.type <= 1 and not selected.is_functional(): _on_Delete_Button_pressed()
	for b in buttons.get_children():
		if b.name != "CursorButton":
			b.pressed = false
		else:
			b.pressed = true
			
	button_type = -1
	pass # replace with function body
	
func _on_ResourceButton_pressed():
	#if selected and selected.type >=2: set_selected()
	if selected and selected.type <= 1 and not selected.is_functional(): _on_Delete_Button_pressed()
	for b in buttons.get_children():
		if b.name != "ResourceButton":
			b.pressed = false
		else:
			if b.pressed:
				button_type = 0
			else:
				button_type = -1




func _on_PoolButton_pressed():

	for b in buttons.get_children():
		if b.name != "PoolButton":
			b.pressed = false
		else:
			if b.pressed:
				button_type = 2
			else:
				button_type = -1
				
func _on_GateButton_pressed():
	for b in buttons.get_children():
		if b.name != "GateButton":
			b.pressed = false
		else:
			if b.pressed:
				button_type = 3
			else:
				button_type = -1
	pass # replace with function body



func _on_SourceButton_pressed():
	for b in buttons.get_children():
		if b.name != "SourceButton":
			b.pressed = false
		else:
			if b.pressed:
				button_type = 4
			else:
				button_type = -1
	pass # replace with function body


func _on_DrainButton_pressed():
	for b in buttons.get_children():
		if b.name != "DrainButton":
			b.pressed = false
		else:
			if b.pressed:
				button_type = 5
			else:
				button_type = -1
	pass # replace with function body


func _on_ConvertButton_pressed():
	for b in buttons.get_children():
		if b.name != "ConvertButton":
			b.pressed = false
		else:
			if b.pressed:
				button_type = 6
			else:
				button_type = -1
	pass # replace with function body



func _on_EndConditionButton_pressed():
	for b in buttons.get_children():
		if b.name != "EndConditionButton":
			b.pressed = false
		else:
			if b.pressed:
				button_type = 7
			else:
				button_type = -1
	pass # replace with function body

func _on_Delay_pressed():
	for b in buttons.get_children():
		if b.name != "Delay":
			b.pressed = false
		else:
			if b.pressed:
				button_type = 8
			else:
				button_type = -1
	pass # replace with function body

func _on_FunctionCall_pressed():
	for b in buttons.get_children():
		if b.name != "FunctionCall":
			b.pressed = false
		else:
			if b.pressed:
				button_type = 9
			else:
				button_type = -1
	pass # replace with function body
	pass # replace with function body


func _on_Delete_Button_pressed():
	var to_delete = selected
	set_selected()
	if to_delete:
		for r in nodes_container.get_children():
			if r.type <=1:
				if typeof(r.start_node) != TYPE_DICTIONARY:
					if r.start_node.get_index() == to_delete.get_index():
						r.start_node = {"position": r.start_node.position, "radius": r.start_node.radius}
				if typeof(r.end_node) != TYPE_DICTIONARY:
					if r.end_node.get_index() == to_delete.get_index():
						r.end_node = {"position": r.end_node.position, "radius": r.end_node.radius}
		to_delete.free()
	_on_CursorButton_pressed()
	pass # replace with function body

func update():
	.update()




