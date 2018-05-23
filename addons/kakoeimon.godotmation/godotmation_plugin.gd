tool
extends EditorPlugin

const godotmation_edit_pck = preload("res://addons/kakoeimon.godotmation/GodotMation_Edit.tscn")

var godotmation_edit = null
var godotmation_button = null


func _enter_tree():
	add_custom_type("GodotMation", "Node", preload("res://addons/kakoeimon.godotmation/godotmation.gd"), preload("res://addons/kakoeimon.godotmation/godotmation.png"))
	godotmation_edit = godotmation_edit_pck.instance()
	godotmation_button = add_control_to_bottom_panel(godotmation_edit, "GodotMation")
	godotmation_button.hide()
	get_editor_interface().get_selection().connect("selection_changed", self, "on_selection_changed")
func _exit_tree():
	apply_changes()
	remove_custom_type("GodotMation")
	remove_control_from_bottom_panel(godotmation_edit)
	godotmation_edit.free()
	print("godotmation exit tree")
	
	
func on_selection_changed():
	apply_changes()
	var selected_nodes = get_editor_interface().get_selection().get_selected_nodes()
	if(selected_nodes.size()!=1):
		godotmation_edit.hide()
		godotmation_button.hide()
		return
	var selected_node = selected_nodes[0]

	if(selected_node is preload("godotmation.gd")):
		godotmation_edit.selected_godotmation = selected_node
		godotmation_edit.build_from_selected()
		if godotmation_button.pressed:
			godotmation_edit.show()
		godotmation_button.show()
	else:
		godotmation_edit.hide()
		godotmation_button.hide()
		
	
func apply_changes():
	if godotmation_edit.selected_godotmation:
		godotmation_edit.build_selected()
		godotmation_edit.selected_godotmation = null
	
func make_visible(visible):
	print(visible)