extends Node2D

var kind := ""
func block(x:int,y:int,w:int,h:int,tint:String):
	draw_rect(Rect2(x,y,w,h),Color(tint))

func _draw():
	match kind:
		"máquina":
			block(-28,-77,56,70,"#122433")
			block(-24,-72,48,63,"#435667")
			block(-20,-66,40,54,"#142f46")
			block(-15,-61,30,46,"#28667b")
			block(-11,-56,22,38,"#4494a1")
			for x in [-26,20]:
				block(x,-66,6,52,"#182d40")
				for y in range(-62,-12,10): block(x+1,y,4,5,"#7bf6d8")
			block(-25,-12,50,6,"#a8c8ca")
			block(-29,-6,58,5,"#273f50")
		"consola","archive","observatory":
			block(-12,-14,24,14,"#2c4050")
			block(-10,-12,20,7,"#83d3cc")
			block(-6,-10,10,1,"#367b86")
			block(-10,-3,14,2,"#98adba")
		"home":
			block(-10,-7,20,10,"#86654d")
			block(-6,-13,12,7,"#263e52")
			block(-4,-11,8,3,"#e5ae68")
		"market","workshop","cafe","tower","kiosk":
			block(-12,-8,24,10,"#735b52")
			block(-12,-9,24,3,"#e3b583")
			block(-5,-13,9,6,"#f5ddb6")
		"seguro":
			block(-6,-5,12,9,"#344653")
			block(-3,-9,6,7,"#e1ad54")
		"cartucho":
			block(-4,-8,8,12,"#97f6c5")
			block(-5,-10,10,3,"#31526b")
			block(-5,3,10,3,"#31526b")
