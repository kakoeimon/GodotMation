############# NUMBER #############
#### Class for integers and floating points.
########## integer anf floating points are the same class cause an integer can be changed to
########## floating point by a state
class number:
	var type = 0

	var label = ""
	var integer = 0
	var floating = 0
	var number = 0.0
	
	func set_from_string(string):
		label = string
		number = float(string)
		convert_value()
		
	func convert_value():
		integer = int(number)
		floating = (number - integer) * 100
		
	func get_value():
		var output = integer
		if floating:
			if randi()%100 <= floating:
				output +=1
		return output
		
	func add_value(v):
		number += v
		convert_value()
		
	func get_label():
		return str(number)
		
	func get_type():
		return type


############# PERCENTAGE ###############
###### Class for percentage values.

class percentage:
	var type = 1

	var label = ""
	var standard = 0
	var chance = 0
	var number = 0
	
	func set_from_string(string):
		label = string + "%"
		var length = string.length()
		var tmp_string = string
		var tmp_chance = ""
		number = int(label)
		set_chance()
		
	func get_value():
		var output = standard
		if randi()%100 <= chance:
			output +=1
		return output
		
	func set_chance():
		standard = int(number / 100)
		chance = number - standard * 100
		
	func add_value(value):
		number += value
		set_chance()
		pass
		
	func get_label():
		return str(number) + "%"
	
	func get_type():
		return type
		
	func get_number():
		return number
		

############ DICE ###############
######Class for dice values
############ it may contain more dices or numbers or percentage
############ if you want to use dice and other values you must begin with the dice and later on
############ with the numbers or percentages. States will not alter other values but will stored
############# in the other_number var.
class dice:
	var type = 2

	var label = "D6"
	
	var number_of_dices = 0
	var number_of_sides = 0
	var other_object_number = null
	var other_number = 0

	func get_type():
		return type
	
	func set_from_string(value):
		label = value
		var new_values = value.split("D")
		number_of_dices = int(new_values[0])
		if not number_of_dices: number_of_dices = 1
		number_of_sides = int(new_values[1])
		pass
	
	
	func get_value():
		var output = 0
		for d in range(number_of_dices):
			output += randi()%number_of_sides +1
		print(other_object_number)
		if other_object_number:
			output +=other_object_number.get_value()
		output += other_number
		return output
		
	func get_label():
		return label
		
	func add_value(value):
		other_number += value