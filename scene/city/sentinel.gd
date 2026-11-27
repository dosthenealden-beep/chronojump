extends Node2D

var phase := 0.0
var cycle := 0
var hits := 0

func _process(delta):
	phase += delta
	if phase >= 3.5:
		phase -= 3.5
		cycle += 1
	queue_redraw()

func radius() -> float:
	return (phase - 1.4) * 100

func _draw():
	if phase < 1.4:
		draw_arc(Vector2.ZERO,10+phase*6,0,TAU,48,Color("#ffbc63"),1)
	else:
		draw_arc(Vector2.ZERO,maxf(0.1,radius()),0,TAU,96,Color("#ff536b"),2)
	draw_rect(Rect2(-9,-11,18,19),Color("#172939"))
	draw_rect(Rect2(-12,-8,5,12),Color("#5c8693"))
	draw_rect(Rect2(7,-8,5,12),Color("#5c8693"))
	draw_rect(Rect2(-6,-6,12,4),Color("#ff7755") if phase<1.4 else Color("#74ffff"))
	for i in range(3-hits):
		draw_rect(Rect2(-7+5*i,5,3,2),Color("#ffca65"))
