tool
extends Node


var node_type = 1 #CONNECTION
var type = 1 #STATE
export(int) var color = 0
export(String) var label = "+1"
export(int) var end = 0
export(int) var start = 0

export(Array, Vector2) var points = []

var input_resources = []
var output_resources = []
var input_states = []
var output_states = []

var start_node
var end_node

export(int) var state_type = 0
export(int) var number = 0
export(int) var other_number = 0

export(int) var thickness



func trigger(value = 0):
	if state_type > 8: return
	if state_type == 0:
		end_node.change_input_state(number * value) #0 for simple numbers
	elif state_type == 1: #Interval number with i
		end_node.change_input_state(number * value, state_type)
		pass
	elif state_type == 2: #Multiplier number with m
		end_node.change_input_state(number * value, state_type)
		pass
	elif state_type == 3: #Probability number with %
		end_node.change_input_state( number * value, state_type)
		pass
	elif state_type == 4: #Range number-number
		if not start_node.get_changed_number() > number and not start_node.get_changed_number() < other_number:
			end_node.active = false
	elif state_type == 5: # 5 for > and >=
		if not start_node.get_changed_number() > number:
			end_node.active = false
	elif state_type == 6: # 6 for < and <=
		if not start_node.get_changed_number() < number:
			end_node.active = false
	elif state_type == 7: # ==
		if not start_node.get_changed_number() == number:
			end_node.active = false
	elif state_type == 8: # !=
		if not start_node.get_changed_number() != number:
			end_node.active = false
	pass
	
func change_state(value):
	number += value
	

func convert_label():
	if not label:
		label = "+1"
		number = 1
		return
		
	get_label_data(label)


func get_label_data(in_label):
	var length = in_label.length()
	var i = 0
	if length:
		#####Starting with number. This is wrong value but it is setted as having + infront
		if in_label[0] == "+" or in_label[0] == "-" or in_label[0].is_valid_integer():
			var minus = false
			state_type = 0 #0 for + and -
			if in_label[0] == "+":
				i +=1
			if in_label[0] == "-":
				state_type = 0 #1 for -
				i +=1
				minus = true
			var number_string = ""
			while i < length and in_label[i].is_valid_integer():
				number_string += in_label[i]
				i +=1 
			number = int(number_string)
			if minus: number *= -1
			if i < length:
				if in_label[i] == ".": #This means that it is a float
					i +=1
					number_string += "."
				while i < length and in_label[i].is_valid_integer():
					number_string += in_label[i]
					i +=1
				number = float(number_string)
				if minus: number *= -1
			if i < length: #This means that it is another state type
				if in_label[i] == "i":
					state_type = 1 #interval modifiers
				elif in_label[i] == "m":
					state_type = 2 #multiplier modofier
				elif in_label[i] == "%":
					state_type = 3 #probability for triggers after gates
				elif in_label[i] == "-":
					state_type = 4 #range conditions 
					var new_num_string = ""
					i +=1
					while i < length and in_label[i].is_valid_integer():
						new_num_string += in_label[i]
						i +=1 
					if new_num_string:
						other_number = int(new_num_string)

		###### Starting with > or >= condition
		elif in_label[0] == ">" or in_label[0] == "<":
			
			i +=1
			var equal = false
			if length > 1 and in_label[1] == "=":
				equal = true
				i +=1
			var number_string = ""
			while i < length and in_label[i].is_valid_integer():
				number_string += in_label[i]
				i +=1 
			
			if number_string:
				number = int(number_string)
			else:
				number = 1
			if in_label[0] == ">":
				state_type = 5 # 5 for > and >=
				if equal: number -= 1 #This way we keep one type for > and >=
			else:
				state_type = 6 # 6 for < and <=
				if equal: number += 1
		################# == 
		elif in_label[0] == "=":
			if length > 0 and in_label[0] == "=":
				state_type = 7 # ==
				i +=2
				var number_string = ""
				while i < length and in_label[i].is_valid_integer():
					number_string += in_label[i]
					i +=1 
				if number_string:
					number = int(number_string)
				else:
					number = 1
		elif in_label[0] == "!" and length > 1:
			if in_label[1] == "=":
				state_type = 8 # !=
				i +=2
				var number_string = ""
				while i < length and in_label[i].is_valid_integer():
					number_string += in_label[i]
					i +=1 
				if number_string:
					number = int(number_string)
				else:
					number = 1
		elif in_label[0] == "*" and length == 1:
			state_type = 9
		elif in_label[0] == "!" and length == 1:
			state_type = 10
				
	#print(number)

func get_dict():
	var dict = {}
	dict.type = type
	dict.color = color
	dict.label = label
	dict.end = end
	dict.start = start
	dict.number = number
	dict.thickness = thickness

	dict.points = []
	for p in points:
		dict.points.append([p.x, p.y])
		
	return dict