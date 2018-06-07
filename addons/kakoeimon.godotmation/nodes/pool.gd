tool
extends Node

#Pool is a node
var type = 2
#The name of the Node (pool) will be changed in the caption,
#in godot only the first same name will not have a suffix. 
export(String) var caption = ""
#Color is just a number.
#the color is taken from a premade array
#see godotmation.gd for the array colors
export(int) var color = 0
#This is not implemented yet but it is for the 
#turn based mode.
export(int) var actions = 0
#Activation mode is the way the node acts in time.
#passive for no action, in godotmation is 0
#interactive for user interaction, in godotmation is 1.
#automatic for nodes that will trigger with the interval loop, in godotmation is 2.
#on start for nodes that will trigger, on the start of the execution, in godotmation is 3.
export(int) var activation_mode = 0
#pull mode is the way the node interacts
#pull any is when the node will pull as much as the incomming resources indicates
#pull all will pull only if they can pull all the resources indicated by the incoming resources.
#push any this push as much resources is possible from this node according to the output resources.
#push all will push all the resources or none
export(int) var pull_mode = 0

#This is for the resource color of the resources.
#This is not used yet...
export(String) var resource_color = ""
#This is the resources this pool will have from the begining.
export(int) var starting_resources = 0
#Number is the number of the resources you have in the pool
export(int) var number = 0

#Capacity of the pool
export(int) var capacity = -1

#For the diagram, it is the place the caption is positioned
export(float) var caption_pos = 0
#Thickness is 2.0 and must be removed
export(int) var thickness = 2
#This is for the position of the node in the machinations diagram
export(Vector2) var position

####### Extra vars for the functionality of the pool

#The connections of the pool, all this are going to be setted in godotmation.gd
#resources
var input_resources = []
var output_resources = []
#and states
var input_states = []
var output_states = []

#The trigger states
var trigger_states = []
#The reverse_trigger_states
var reverse_trigger_states = []
#The input_conditional_states, those states are used in apply_state to activate or diactivate the pool
var input_conditional_states = []

#This is used for communication with other godot objects
signal state_changed
#and the bool for checking if we want an emittion to happen.
export(bool) var emit_state_changed = false

#This is used to turn on and off the pool node, it is used by the conditional input states
export(bool) var active = true

#input_number is the number of the resources that are going to get in the pool, 
#the change in number will be applied when apply_change is called
var input_number = 0

#output_number is the number of the resources that are going to be pushed
var output_number = 0

#wanted_number exists to store the number of resources the pool requires to get satisfied.
#Satisfaction will trigger the trigger_states which are the states with an *
var wanted_number = 0

#wanted_input exists to check if the pool gathered all the resource flow for the resource connections
#it is used to check satisfaction and trigger the reverse_triggers if not.
var wanted_input = 0

var satisfied = true

#pushed is used to check if a node had pushed resources to this node. This means that this node was 
#is the end of a resource connection that have a start node with pull_mode push_any or push all.
var pushed = false


#The trigger method does not need a value, pool node will try to sutisfie the resource flow
#of the resource conections acording to the pull mode
#The push any and push all will call the pull any or pull all acordingly to the node to the end of the connection
#For this reason avoid the connection of two push nodes.
func trigger():
	if not active: return
	#var satisfied = true
	##################PULL ANY
	if pull_mode == 0: #pull any
		for r in input_resources:
			if not r.trigger():
				satisfied = false
		##################PULL ALL
	elif pull_mode == 1: #pull all
		for r in input_resources:
			if not r.can_push_all():
				satisfied = false
				break
		if satisfied:
			for r in input_resources:
				r.trigger()
		##################PUSH ANY
	elif pull_mode == 2: #push any
		#here push any just triggers the end node of the connections.
		for r in output_resources:
			r.end_node.pull_resources(r)
			
		##################PUSH ALL
	elif pull_mode == 3: #push all
		for r in output_resources:
			if not r.can_push_all():
				satisfied = false
				break
		if satisfied:
			for r in output_resources:
				r.end_node.pull_resources(r)
	
	if satisfied:
		for r in input_resources:
			r.update_flow()
		for s in trigger_states:
			s.end_node.trigger()
	for r in input_resources:
		if not r.satisfied:
			for s in reverse_trigger_states:
				s.end_node.trigger()
			break
	pass


func pull_resources(resource):
	if not active: return
	pushed = true
	if not resource.trigger():
		satisfied = false

	
func apply_satisfaction():
	for r in input_resources:
		if not r.used: satisfied = false
		if not r.satisfied or not r.used:
			for s in reverse_trigger_states:
				s.end_node.trigger()
			break
	if satisfied:
		for r in input_resources:
			r.update_flow()
		for s in trigger_states:
			s.end_node.trigger()
	pushed = false
	

#can_push is used for checking if a node can push a number of resources.
#It is used by pull all and push all
func can_push(value):
	if value <= number + output_number:
		return value
	return max(0, number + output_number)


#This function is to change the input_number and trigger the output states
func change_input_state(value): 
	input_number += value
	#value is and the state change in fact so we trigger the output states with this value
	for s in output_states:
		s.trigger(value)
	return input_number


#This function is to change the output_number and trigger the output states
func change_output_state(value):
	if value > number + output_number:
		print(value)
	output_number += value
	#value is and the state change in fact so we trigger the output states with this value
	for s in output_states:
		s.trigger(value)
	return value

#get_changed_number is used to get the fouture number of the pool
func get_changed_number():
	return number + output_number + input_number

func get_output_number():
	return number + output_number
	
func get_input_number():
	return number + input_number

#apply_state is used after all automatic nodes are triggered
func apply_state():
	if output_number or input_number:
		number += output_number + input_number
		
		if emit_state_changed: emit_signal("state_changed" , number)
		
		output_number = 0
		input_number = 0
	satisfied = true
	#active is setted here as true and this may change by the input_conditional_states
	active = true
	for s in input_conditional_states:
		s.trigger()

func get_dict():
	var dict = {}
	dict.type = type
	dict.caption = caption
	dict.color = color
	dict.actions = actions
	dict.activation_mode = activation_mode
	dict.pull_mode = pull_mode
	dict.resource_color = resource_color
	dict.starting_resources = starting_resources
	dict.number = number
	dict.capacity = capacity
	dict.caption_pos = caption_pos
	dict.thickness = thickness
	dict.x = position.x
	dict.y = position.y
	dict.emit_state_changed = emit_state_changed
	
	return dict

#This function is to be used by external code.
#For example to change the number of the pool to much an arg of a connected signal to the pool
func force_number(value):
	number = value