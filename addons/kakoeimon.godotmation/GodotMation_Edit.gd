tool
extends Control

var selected_godotmation = null

var colors = [Color(0,0,0), Color(1,1,1)]

var godotmation_name = ""
export(float) var version
###### name
export(String) var author

export(float) var interval = 1.0
export(int) var time_mode
export(int) var distribution_mode
export(int) var speed
export(int) var actions = 0
export(String) var dice = "D6"

export(String) var skill = ""
export(String) var strategy = ""
export(String) var multiplayer_skill = ""

export(int) var width
export(int) var height

export(int) var number_of_runs
export(int) var visible_runs
const tools = preload("GodotMation_xml_json_tools.gd")

var nodes = []
var resources = []
var states = []

######### EDITOR VARS
onready var drawing_area = $DrawingArea
onready var drawing_area_nodes = $DrawingArea/Nodes
var selected_color = 0

onready var pull_menu = $Panel/Nodes/PullMode/PullMode
enum pull_modes {pull_any, pull_all, push_any, push_all}
onready var activation_menu = $Panel/Nodes/Activation/ActivationMode
enum activation_modes {passive, interactive, automatic, on_start}
onready var node_caption = $Panel/Nodes/Caption/Caption_LineEdit
onready var node_thickness = $Panel/Nodes/Thickness/SpinBox
onready var node_color = $Panel/Nodes/Color/ColorRect
onready var node_actions = $Panel/Nodes/Actions/SpinBox
onready var node_pull_mode = $Panel/Nodes/PullMode/PullMode
onready var node_number = $Panel/Nodes/Number
onready var node_capacity = $Panel/Nodes/Capacity
onready var gate_type = $Panel/Nodes/GateType
onready var pool_emit = $Panel/Nodes/Pool_Signal/Pool_Signal_CheckBox
onready var queue = $Panel/Nodes/Queue/Queue_CheckBox
onready var signaller = $Panel/Nodes/Signaller/Signaller_CheckBox

onready var connection_label = $Panel/Connections/Label/Label_LineEdit



func _ready():
	pull_menu.get_popup().clear()
	activation_menu.get_popup().clear()
	gate_type.get_node("GateType").get_popup().clear()
	_add_pull_mode_menu()
	_add_activation_mode_menu()
	_add_gate_type_mode_menu()
	
	#_set_main_menu()
	connect("resized", self, "_resized")
	pass

func _process(delta):
	#if Engine.is_editor_hint():

	var godotmation
	if drawing_area.playing:
		godotmation = $play_godotmation.get_child(0)
		for i in range(drawing_area_nodes.get_child_count()):
			var c1 = drawing_area_nodes.get_child(i)
			var c2 = godotmation.get_child(i)
			if c1.type == 2:
				c1.get_node("Number").text = str(c2.number)
			elif c1.type == 0 and c2 and c2.type <=1:
				c1.get_node("Label").text = c2.get_label()

func _clear():
	nodes = []
	resources = []
	states = []
	drawing_area.set_selected()
	for node in drawing_area_nodes.get_children():
		node.free()
		
		
func _add_pull_mode_menu():
	var popup = pull_menu.get_popup()
	popup.add_check_item("Pull Any", pull_modes.pull_any)
	popup.add_check_item("Pull All", pull_modes.pull_all)
	popup.add_check_item("Push Any", pull_modes.push_any)
	popup.add_check_item("Push All", pull_modes.push_all)

	pull_menu.text = popup.get_item_text(0)

	popup.connect("id_pressed", self, "_pull_mode_changed")

func _pull_mode_changed(id):
	if drawing_area.selected != null:
		drawing_area.selected.pull_mode = id
		pull_menu.text = pull_menu.get_popup().get_item_text(id)
		drawing_area.selected.update()
	pass
	
func _add_activation_mode_menu():
	var popup = activation_menu.get_popup()
	popup.add_check_item("Passive", activation_modes.passive)
	popup.add_check_item("Interactive", activation_modes.interactive)
	popup.add_check_item("Automatic", activation_modes.automatic)
	popup.add_check_item("On Start", activation_modes.on_start)

	activation_menu.text = popup.get_item_text(0)

	popup.connect("id_pressed", self, "_activation_mode_changed")

func _activation_mode_changed(id):
	if drawing_area.selected != null:
		drawing_area.selected.activation_mode = id
		activation_menu.text = activation_menu.get_popup().get_item_text(id)
		drawing_area.selected.update()
	pass

func _add_gate_type_mode_menu():
	var gate_type_menu = gate_type.get_node("GateType")
	var popup = gate_type_menu.get_popup()
	popup.add_check_item("Deterministic", 0)
	popup.add_check_item("Dice-Random", 1)
	popup.add_check_item("Skill", 2)
	popup.add_check_item("Multiplayer", 3)
	popup.add_check_item("Strategy", 4)

	gate_type_menu.text = popup.get_item_text(0)

	popup.connect("id_pressed", self, "_gate_type_changed")

func _gate_type_changed(id):
	var gate_type_menu = gate_type.get_node("GateType")
	if drawing_area.selected != null:
		drawing_area.selected.gate_type = id
		gate_type_menu.text = gate_type_menu.get_popup().get_item_text(id)
		drawing_area.selected.update()
	pass


func build_from_selected():
	_clear()
	tools._build_from_dict(self, selected_godotmation.get_dict(), true)
	for n in drawing_area_nodes.get_children():
		if n.type <= 1:
			var start_node = drawing_area_nodes.get_child(n.start)
			var end_node = drawing_area_nodes.get_child(n.end)
			n.start_node = start_node
			if end_node.type <=1:
				end_node = end_node.get_connection_point()
			n.end_node = end_node
			
	
	$Panel/Main/Author/Author_LineEdit.text = author
	$Panel/Main/Interval/Label/Interval_SpinBox.value = interval
	$Panel/Main/Dice/Dice_LineEdit.text = dice
	$Panel/Main/Skill/Skill_LineEdit.text = skill
	$Panel/Main/Multiplayer/Multiplayer_LineEdit.text = multiplayer_skill
	$Panel/Main/Strategy/Strategy_LineEdit.text = strategy
	

func build_selected():
	if not selected_godotmation: return
	selected_godotmation._clear()
	tools._build_from_dict(selected_godotmation, _get_dict(), false, true)

func _on_LoadButton_pressed():
	$LoadFileDialog.popup()
	pass # replace with function body



func _on_LoadFileDialog_file_selected(path):
	
	var dict
	if path.split(".xml").size() > 1:
		dict = tools.parse_xml(path)
		
	elif path.split(".json").size() > 1:
		dict = tools.load_json(path)
	if dict: 
		_clear()
		tools._build_from_dict(self, dict, true)
		_set_main_menu()



func _on_SaveButton_pressed():
	$SaveFileDialog.popup()
	pass # replace with function body


func _on_SaveFileDialog_file_selected(path):
	var file = File.new()
	if path.split(".json").size() > 1:
		var dict = _get_dict()
		file.open(path, File.WRITE)
		file.store_string(to_json(dict))
		file.close()

func _get_dict():
	var dict = {}
	dict["version"] = version
	dict["name"] = godotmation_name
	dict["author"] = author
	dict["interval"] = interval
	dict["time_mode"] = time_mode
	dict["distribution_mode"] = distribution_mode
	dict["speed"] = speed
	dict["actions"] = actions
	dict["dice"] = dice
	dict["skill"] = skill
	dict["strategy"] = strategy
	dict["multiplayer"] = multiplayer_skill
	dict["width"] = width
	dict["height"] = height
	dict["number_of_runs"] = number_of_runs
	dict["visible_runs"] = visible_runs
	dict["color_coding"] = false
	
	dict["nodes"] = []
	
	
	for node in drawing_area_nodes.get_children():
		var d = node.get_dict()
		if d:
			dict.nodes.append(d)
	return dict

func _set_main_menu():
	$Panel/Main/Author/Author_LineEdit.text = author
	$Panel/Main/Interval/Label/Interval_SpinBox.value = interval
	$Panel/Main/Dice/Dice_LineEdit.text = dice
	$Panel/Main/Skill/Skill_LineEdit.text = skill
	$Panel/Main/Multiplayer/Multiplayer_LineEdit.text = multiplayer_skill
	$Panel/Main/Strategy/Strategy_LineEdit.text = strategy

func _set_node_tab(selected):
	if selected.type >= 2:
		$Panel/Nodes.show()
		$Panel/Connections.hide()
		node_caption.text = selected.caption
		node_thickness.value = selected.thickness
		#node_color
		#node_activation
		node_actions.value = selected.actions
		activation_menu.text = activation_menu.get_popup().get_item_text( selected.activation_mode )
		pull_menu.text = pull_menu.get_popup().get_item_text(selected.pull_mode)
		if selected.type == 2:
			node_number.show()
			node_capacity.show()
			pool_emit.get_parent().show()
			node_number.get_node("Number_SpinBox").value = selected.starting_resources
			node_capacity.get_node("SpinBox").value = selected.capacity
			pool_emit.pressed = selected.emit_state_changed
		else:
			node_number.hide()
			node_capacity.hide()
			pool_emit.get_parent().hide()
		if selected.type == 3:
			var gate_type_menu = gate_type.get_node("GateType")
			gate_type_menu.text = gate_type_menu.get_popup().get_item_text(selected.gate_type)
			gate_type.show()
		else:
			gate_type.hide()
		if selected.type == 7:
			queue.get_parent().show()
			queue.pressed = selected.queue
		else:
			queue.get_parent().hide()
		if selected.type == 8:
			signaller.get_parent().show()
			signaller.pressed = selected.signaller
		else:
			signaller.get_parent().hide()
	else:
		$Panel/Nodes.hide()
		$Panel/Connections.show()
		connection_label.text = selected.label

func _on_PlayButton_pressed():
	for c in $play_godotmation.get_children():
		c.free()
	var godotmation = preload("godotmation.tscn").instance()
	$play_godotmation.add_child(godotmation)
	tools._build_from_dict(godotmation, _get_dict(), false, false)
	godotmation.setup()
	godotmation._start()
	drawing_area.playing = true
	set_process(true)
	pass # replace with function body

func _connect_godotmation(godotmation):
	for i in range(drawing_area_nodes.get_child_count()):
		if drawing_area_nodes.get_child(i).type == 2:
			godotmation.get_child(i).connect("state_changed", drawing_area_nodes.get_child(i), "change_number")
			
func _on_StopButton_pressed():
	for n in drawing_area_nodes.get_children():
		if n.type == 2:
			n.get_node("Number").text = str(n.starting_resources)
		elif n.type <= 1:
			n.get_node("Label").text = n.label
	for c in $play_godotmation.get_children():
		c.free()
	drawing_area.playing = false
	pass # replace with function body



func _on_Caption_LineEdit_text_changed(new_text):
	var selected = drawing_area.selected
	if selected:
		selected.set_caption(new_text)
		selected.update()
	pass # replace with function body


func _on_Number_SpinBox_value_changed(value):
	var selected = drawing_area.selected
	if selected:
		selected.set_starting_resources(value)
		selected.update()
	pass # replace with function body

func _on_Pool_Signal_CheckBox_toggled(button_pressed):
	var selected = drawing_area.selected
	if selected:
		selected.emit_state_changed = button_pressed
	pass # replace with function body

func _on_Queue_CheckBox_toggled(button_pressed):
	var selected = drawing_area.selected
	if selected:
		selected.queue = button_pressed
		selected.update()

func _on_Signaller_CheckBox_toggled(button_pressed):
	var selected = drawing_area.selected
	if selected:
		selected.signaller = button_pressed
		selected.update()

#####CONECTION MENUS RETURN

func _on_Label_LineEdit_text_changed(new_text):
	var selected = drawing_area.selected
	if selected:
		selected.label = new_text
		selected.get_node("Label").text = new_text
		selected.update()
	pass # replace with function body


func _resized():
	var panel_size = $Panel.rect_min_size
	drawing_area.rect_size = rect_size - panel_size


func _on_Author_LineEdit_text_changed(new_text):
	author = new_text


func _on_Interval_SpinBox_value_changed(value):
	interval = value

func _on_Dice_LineEdit_text_changed(new_text):
	dice = new_text


func _on_Skill_LineEdit_text_changed(new_text):
	skill = new_text


func _on_Multiplayer_LineEdit_text_changed(new_text):
	multiplayer_skill = new_text


func _on_Strategy_LineEdit_text_changed(new_text):
	strategy = new_text




