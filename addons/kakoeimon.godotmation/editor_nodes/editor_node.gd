extends Node2D


export(String) var caption = ""
export(Vector2) var caption_pos

export(int) var actions = 1
export(int) var activation_mode = 0
export(int) var pull_mode = 0
export(int) var color = 0
export(int) var thickness = 2


var radius = 20

func _ready():
	set_caption(caption)


func to_select(pos):
	if abs(pos.x - position.x) <= radius and abs(pos.y - position.y) <= radius:
		return true
	return false
	
func set_caption(value = ""):
	#if not value: return
	$Caption.text = value
	caption = value
	
func get_base_dict():
	var dict = {}
	dict.name = name
	dict.caption = caption
	dict.caption_pos = caption_pos
	dict.actions = actions
	dict.activation_mode = activation_mode
	dict.pull_mode = pull_mode
	dict.color = color
	dict.thickness = thickness
	dict.x = position.x
	dict.y = position.y
	return dict