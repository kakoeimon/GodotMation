extends Button


func _pressed():
	._pressed()
	update()

func _draw():
	var length = get_rect().size.x
	
	var cp = 0.5
	var cnp = 0.2
	var o = 0.2
	var c = Color(0, 0, 0, cnp)
	if pressed:
		c = Color(0, 0, 0, cp)
	draw_rect(Rect2(Vector2(), get_rect().size), c, true)
	draw()

func draw():
	pass
	
