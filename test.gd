tool
extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var godotmation = get_child(0)
	godotmation._interval_timeout()
	
	var time = OS.get_ticks_msec()
	for i in range(0,400):
		godotmation._interval_timeout()
	print(OS.get_ticks_msec() - time)
	
	pass

func test_number():
	return 62
