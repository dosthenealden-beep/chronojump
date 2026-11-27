extends Node2D

func _draw():
	draw_colored_polygon(PackedVector2Array([Vector2(0,-6),Vector2(5,-1),Vector2(0,4),Vector2(-5,-1)]),Color("#172e43"))
	draw_colored_polygon(PackedVector2Array([Vector2(0,-4),Vector2(3,-1),Vector2(0,2),Vector2(-3,-1)]),Color("#ffe18a"))
	if objective:
		draw_arc(Vector2(0,-1),8,0,TAU,24,Color("#62ffee"),2)
var objective := false
