class unequal:
	var type = 3
	var number = 0

	func compare(value):
		return value != number
		
	func get_label():
		return "!=" + str(number)
		
	func get_type():
		return type



class equal:
	var type = 4
	var number = 0

	func compare(value):
		return value == number
	
	func get_label():
		return "==" + str(number)
		
	func get_type():
		return type



class higher:
	var type = 5
	var number = 0

	func compare(value):
		return value > number
	
	func get_label():
		return ">" + str(number)
		
	func get_type():
		return type



class lower:
	var type = 6
	var number = 0

	func compare(value):
		return value < number
		
	func get_label():
		return "<" + str(number)
		
	func get_type():
		return type

