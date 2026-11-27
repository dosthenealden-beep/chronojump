extends Node2D
func _ready():
	$Mirador.draw.connect(draw_skyline)
func draw_skyline():
	var art:Node2D=$Mirador
	art.draw_rect(Rect2(20,12,312,70),Color("#101b39"))
	for i in range(21):
		var height := 16+posmod(i*23,49)
		var x := 23+i*15
		art.draw_rect(Rect2(x,80-height,12,height),Color("#284460"))
		for y in range(83-height,77,6):
			art.draw_rect(Rect2(x+2,y,7,2),Color("#6de9dc") if i%2==0 else Color("#ed9deb"))
	art.draw_rect(Rect2(18,80,316,4),Color("#568595"))
	art.draw_rect(Rect2(220,93,12,15),Color("#a86dce"))
	art.draw_rect(Rect2(222,85,8,9),Color("#b77750"))
	art.draw_rect(Rect2(221,84,10,4),Color("#403040"))
