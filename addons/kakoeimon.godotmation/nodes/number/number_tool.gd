static func from_string(string):
	var label = string.replace(" ", "")
	var length = label.length()
	if length:
		if label[0] != "+" and label[0] != "-" and label[0] != "!" and label[0] != "=" and label[0] != ">" and label[0] != "<":
			return read_string("+" + label)
		else:
			return read_string(label)
	pass
	

static func read_string(l):
	var number = preload("number.gd")
	var condition = preload("condition.gd")
	
	var length = l.length()
	var i = 0
	var number_string = ""
	if length:
		if l[i] == "+":
			number_string += "+"
			i +=1
		elif l[i] == "-":
			number_string += "-"
			i +=1
		

		if l[i].is_valid_integer():
			while i < length and l[i].is_valid_integer():
				number_string += l[i]
				i +=1
			if i < length:
				if l[i] == ".":
					number_string += "."
					i +=1
					while i < length and l[i].is_valid_integer():
						number_string += l[i]
						i +=1
					var value = number.number.new()
					value.set_from_string(number_string)
					return value
				elif l[i] == "%":
					i +=1
					var value = number.number.new()
					number_string = number_string.left(number_string.length() - 2) + "." + number_string.right(number_string.length() - 2)
					value.set_from_string(number_string)
					return value
				elif l[i] == "D":
					i +=1
					number_string += "D"
					while i < length and l[i].is_valid_integer():
						number_string += l[i]
						i +=1
					var value = number.dice.new()
					value.set_from_string(number_string)
					if i < length:
						value.other_object_number = from_string(l.right(i))
					return value
				else:
					var value = number.number.new()
					value.set_from_string(number_string)
					return value
			else:
				var value = number.number.new()
				value.set_from_string(number_string)
				return value

		elif l[i] == "D":
			i +=1
			number_string += "D"
			while i < length and l[i].is_valid_integer():
				number_string += l[i]
				i +=1
			var value = number.dice.new()
			value.set_from_string(number_string)
			if i < length:
				value.other_object_number = from_string(l.right(i))
			return value
		elif l[i] == "!":
			i +=1
			if i == length:
				return #reverse_trigger this is for state connections only
			
			if l[i] == "=":
				var value = condition.unequal.new()
				i +=1
				number_string = ""
				while i < length and l[i].is_valid_integer():
					number_string += l[i]
					i +=1
				value.number = int(number_string)
				return value
		elif l[i] == "=":
			i +=1
			if l[i] == "=":
				var value = condition.equal.new()
				i +=1
				number_string = ""
				while i < length and l[i].is_valid_integer():
					number_string += l[i]
					i +=1
				value.number = int(number_string)
				return value
		elif l[i] == ">":
			var equal = false
			i +=1
			if l[i] == "=":
				equal = true
				i +=1
			var value = condition.higher.new()
			number_string = ""
			while i < length and l[i].is_valid_integer():
				number_string += l[i]
				i +=1
			if equal:
				value.number = int(number_string) - 1
			else:
				value.number = int(number_string)
			return value
		elif l[i] == "<":
			var equal = false
			i +=1
			if l[i] == "=":
				equal = true
				i +=1
			var value = condition.lower.new()
			number_string = ""
			while i < length and l[i].is_valid_integer():
				number_string += l[i]
				i +=1
			if equal:
				value.number = int(number_string) + 1
			else:
				value.number = int(number_string)
			return value
	pass

