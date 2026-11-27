extends Control
const CITY = preload("res://city_guide.png")
const KEYS = ["home","archive","secret_lab","market","kiosk","observatory","workshop","cafe","tower"]
const NAMES = ["Residencias Alba","Centro Cívico Aurora","Parque del Reloj · Caseta","Mercado Central","Plaza del Encuentro","Distrito del Observatorio","Pasaje del Sol","Paseo de los Álamos","Torres del Sur"]
var here := Vector2.ZERO
var goal := ""
var location := ""
func open_map(room: String, pos: Vector2, destination: String):
	location = room
	here = pos
	goal = destination
	queue_redraw()
func _draw():
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0,0,960,600),Color("#132235"))
	draw_string(font,Vector2(35,70),"NUEVA AURORA   /   Plano del presente",HORIZONTAL_ALIGNMENT_LEFT,-1,28)
	draw_texture(CITY,Vector2(32,110))
	for i in range(9):
		var center := Vector2(32+int(i%3)*187+92,110+floori(i/3.0)*119+59)
		var color := Color("#ffe183") if goal==KEYS[i] else Color.WHITE
		draw_circle(center,12,Color("#162236"))
		draw_string(font,center+Vector2(-5,6),str(i+1),HORIZONTAL_ALIGNMENT_LEFT,-1,16,color)
		draw_string(font,Vector2(630,135+34*i),str(i+1)+". "+NAMES[i],HORIZONTAL_ALIGNMENT_LEFT,-1,17,color)
		if location==KEYS[i]: draw_arc(center,16,0,TAU,32,Color.AQUAMARINE,3)
	if location=="present_world":
		draw_circle(Vector2(32,110)+here*0.5,6,Color.AQUAMARINE)
	draw_string(font,Vector2(32,518),"Turquesa: tu posición     Amarillo: destino de la misión",HORIZONTAL_ALIGNMENT_LEFT,-1,18)
	draw_string(font,Vector2(32,555),"M / Esc   Volver al juego",HORIZONTAL_ALIGNMENT_LEFT,-1,17)
