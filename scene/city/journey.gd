extends Node2D

const Hero = preload("res://hero.gd")
const Sentinel = preload("res://sentinel.gd")
const Sign = preload("res://waypoint.gd")
const DOORS = {
	"home": Vector2(64,136), "archive": Vector2(456,138), "secret_lab": Vector2(1072,216),
	"market": Vector2(60,378), "kiosk": Vector2(550,438), "observatory": Vector2(1000,412),
	"workshop": Vector2(65,652), "cafe": Vector2(453,646), "tower": Vector2(882,684)
}
const NAMES = {
	"arrival":"Nueva Aurora · Año 2147","present_world":"Nueva Aurora", "home":"Residencias Alba · Tu casa", "archive":"Centro Cívico Aurora · Archivo",
	"secret_lab":"Laboratorio Umbral", "market":"Mercado Central", "kiosk":"Plaza del Encuentro · Quiosco",
	"observatory":"Distrito del Observatorio", "workshop":"Pasaje del Sol · Taller", "cafe":"Paseo de los Álamos · Café", "tower":"Torres del Sur · Vestíbulo"
}
const NOTES = {
	"home":"La cinta está fechada mañana. Es tu voz, con el mismo tropiezo que haces al decir «reloj». «Busca el recibo del Mercado. Si entro sin saber cómo volver, voy a quedarme allí».",
	"market":"La vendedora reconoce la cinta. «Vera compró el último cartucho y dejó su credencial por si alguien venía a buscarla». El recibo lleva el sello del archivo municipal.",
	"archive":"Expediente UMBRAL. Vera, tu hermana, rastreó los apagones hasta la caseta del parque. Anotó el código en el reverso: 04–17. Su última transmisión llegó con fecha de mañana.",
	"kiosk":"El aviso municipal dice que el reloj del parque se atrasa un minuto con cada apagón. Alguien escribió debajo: «Solo pasa cuando la caseta enciende la luz».",
	"observatory":"La astrónoma te enseña dos registros idénticos, separados por un día. «El cielo no se repite así. Nuestro instrumento está recibiendo la lectura de mañana».",
	"workshop":"El mecánico reconoce el modelo del guardián. «La luz ámbar anuncia un pulso. Si te alcanza, el sistema te devuelve al punto de seguridad. Busca sus tres interruptores».",
	"cafe":"En una servilleta, Vera dibujó dos casillas: IDA y VUELTA. Solo marcó la primera. Debajo escribió: «Un cartucho, un salto».",
	"tower":"El portero recuerda a Vera. «A las cuatro y diecisiete la vi entrar al parque. Después llamó desde este mismo vestíbulo. Yo estaba aquí; no había nadie»."
}
const GOALS = ["Escucha la cinta en tu casa.","Busca el recibo en el Mercado Central.","Lee el expediente en el Centro Cívico.","Abre la caseta del Parque del Reloj.","Rearma la consola del laboratorio.","Desactiva los tres seguros de CUSTODIO.","Recoge el cartucho que protegía CUSTODIO.","Carga la máquina y activa el primer salto.","Primer salto completado."]
const LOCKS = [Vector2(270,163),Vector2(450,215),Vector2(340,52)]
const HOT = Vector2(172,84)
var stage := 0
var room := ""
var level: Node2D
var player: CharacterBody2D
var boss
var used := {}
var hp := 3
var last_pulse := -1
var ui: Label
var prompt: Label
var story: Label
var guidance: Label
var points := {}
var nearest := ""
var nearest_distance := 25.0
var ending := false
var jumping := false
var guide: Control
var route: Label
var curtain: ColorRect
const TARGET_ROOMS = ["home","market","archive","secret_lab","secret_lab","secret_lab","secret_lab","secret_lab"]
const DESTINATIONS = ["Residencias Alba","Mercado Central","Centro Cívico","Laboratorio Umbral"]
func target_key() -> String:
	if stage >= 8: return "Vera"
	if room == "present_world": return TARGET_ROOMS[stage]
	if room != TARGET_ROOMS[stage]: return "salir"
	if stage <= 2: return "investigar"
	if stage == 4: return "consola"
	if stage == 5:
		for i in range(3):
			if not used.has("seguro"+str(i)): return "seguro"+str(i)
	return "cartucho" if stage == 6 else "máquina"

func label_at(parent: Node, pos: Vector2, size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_constant_override("outline_size",5)
	label.add_theme_color_override("font_outline_color",Color("#101d30"))
	parent.add_child(label)
	return label

func _ready():
	var preview := get_node("CityInEditor")
	remove_child(preview)
	preview.free()
	var hud := CanvasLayer.new()
	add_child(hud)
	ui = label_at(hud,Vector2(14,8),17)
	guidance = label_at(hud,Vector2(14,62),15)
	prompt = label_at(hud,Vector2(14,89),17)
	story = label_at(hud,Vector2(14,128),17)
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story.size.x = minf(590,get_viewport_rect().size.x-30)
	route = label_at(hud,Vector2(14,110),16)
	story.position.y = 148
	guide = preload("res://city_guide.gd").new()
	hud.add_child(guide)
	guide.hide()
	curtain = ColorRect.new()
	curtain.color = Color(0.35,0.95,1,0)
	curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(curtain)
	curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	enter("present_world",Vector2(74,154))
	say("NUEVA AURORA · 04:17\nVuelves a casa cuando suena el reloj del parque. Lleva años parado. Bajo la puerta de tu apartamento asoma una cinta con tu letra. Acércate a la entrada iluminada y pulsa E.")

func say(words: String):
	story.text = words + "\n[Espacio o E para continuar]"

func enter(id: String, at: Vector2):
	if is_instance_valid(level):
		remove_child(level)
		level.queue_free()
	room = id
	level = load("res://"+id+".tscn").instantiate()
	add_child(level)
	var overview = level.get_node_or_null("MapOverview")
	if overview: overview.enabled = false
	player = Hero.new()
	level.add_child(player)
	player.position = at
	var cam := Camera2D.new()
	cam.zoom = Vector2(1.55,1.55) if id == "present_world" else Vector2(2,2)
	if id == "present_world":
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = 1152
		cam.limit_bottom = 720
	player.add_child(cam)
	cam.make_current()
	points.clear()
	nearest = ""
	boss = null
	if id == "arrival":
		point("Vera",Vector2(228,108))
	elif id == "present_world":
		for door in DOORS: point(door,DOORS[door])
	elif id == "secret_lab":
		point("salir",Vector2(96,279))
		point("consola",Vector2(112,74))
		for i in range(3): point("seguro"+str(i),LOCKS[i])
		point("cartucho",Vector2(386,218))
		point("máquina",Vector2(368,200))
		if stage == 5: spawn_boss()
	else:
		point("salir",Vector2(174,198))
		point("investigar",HOT)
	refresh()

func point(key: String, at: Vector2):
	var dot := Sign.new()
	dot.position = at
	dot.z_index = 5
	level.add_child(dot)
	if room != "present_world" and key != "salir" and key != "Vera":
		var detail = preload("res://interior_detail.gd").new()
		detail.kind = room if key == "investigar" else ("seguro" if key.begins_with("seguro") else key)
		detail.position = Vector2(0,-6)
		detail.z_index = -1
		dot.add_child(detail)
	points[key] = dot

func spawn_boss():
	boss = Sentinel.new()
	boss.position = Vector2(392,148)
	boss.z_index = 6
	level.add_child(boss)
	boss.hits = used.size()
	last_pulse = -1

func available(k: String) -> bool:
	if k.begins_with("seguro"): return stage == 5 and not used.has(k)
	if k == "cartucho": return stage == 6
	if k == "máquina": return stage >= 7
	return true

func refresh():
	ui.text = NAMES[room]+"   ·   Integridad "+str(hp)+"/3\n"+GOALS[stage]
	guidance.text = "Mover: WASD o flechas    ·    Interactuar: E    ·    Esquivar: Shift" if stage != 5 else "CUSTODIO · Seguros liberados: %d/3 · Esquiva los anillos con Shift" % used.size()
	for k in points:
		points[k].visible = available(k)
		points[k].set("objective", k == target_key())
		points[k].queue_redraw()

func _physics_process(_delta):
	player.set_physics_process(story.text.is_empty() and not guide.visible and not jumping)
	if is_instance_valid(boss): boss.set_process(story.text.is_empty() and not guide.visible)
	if guide.visible or jumping: return
	if room != "present_world" and room != "arrival" and story.text.is_empty():
		var door_pos := Vector2(96,289) if room == "secret_lab" else Vector2(176,209)
		if absf(player.position.x-door_pos.x)<14 and player.position.y >= door_pos.y:
			act("salir")
			return
	var target = points.get(target_key())
	route.text = ""
	if target and story.text.is_empty() and not ending:
		var offset: Vector2 = target.position-player.position
		var arrows = ["→","↘","↓","↙","←","↖","↑","↗"]
		var direction = arrows[posmod(roundi(offset.angle()/(PI/4)),8)]
		var caption = NAMES.get(target_key(),target_key().capitalize())
		if target_key()=="salir": caption="Salida a Nueva Aurora"
		route.text = "%s  %s   ·   M: plano de la ciudad" % [direction,caption]
	if is_instance_valid(boss):
		boss.set_process(story.text.is_empty())
		if story.text.is_empty() and boss.phase > 1.4 and player.get("dodge_time") <= 0 and boss.cycle != last_pulse:
			if absf(player.position.distance_to(boss.position)-boss.radius()) < 7:
				last_pulse = boss.cycle
				hp -= 1
				if hp == 0:
					hp = 3
					player.position = Vector2(115,148)
					say("El protocolo te devuelve a la zona segura. Los seguros que soltaste siguen abiertos.")
				refresh()
	nearest = ""
	nearest_distance = 25
	for k in points:
		var dist := player.position.distance_to((points[k] as Node2D).position)
		if available(k) and dist < nearest_distance:
			nearest = k
			nearest_distance = dist
	prompt.text = ""
	if nearest != "" and story.text.is_empty() and not ending:
		prompt.text = "E · "+str(NAMES.get(nearest,nearest.capitalize()))

func _unhandled_key_input(event: InputEvent):
	if not (event is InputEventKey) or not event.pressed or event.echo: return
	if jumping: return
	if event.keycode == KEY_M:
		guide.visible = not guide.visible
		if guide.visible: guide.call("open_map",room,player.position, TARGET_ROOMS[stage] if stage<8 else "")
		return
	if guide.visible:
		if event.keycode == KEY_ESCAPE: guide.hide()
		return
	if event.keycode not in [KEY_E,KEY_SPACE]: return
	if not story.text.is_empty():
		story.text = ""
		return
	if nearest == "" or event.keycode != KEY_E: return
	act(nearest)

func act(k: String):
	if room == "arrival" and k == "Vera":
		ending = true
		finish_chapter()
		return
	if room == "present_world":
		if k == "secret_lab" and stage < 3:
			say("La cerradura tiene cuatro dígitos. El panel lleva el sello del archivo municipal.")
			return
		if k == "secret_lab" and stage == 3: stage = 4
		enter(k, Vector2(96,264) if k == "secret_lab" else Vector2(174,178))
	elif k == "salir":
		enter("present_world",DOORS[room]+Vector2(0,4))
	elif k == "investigar":
		if (room == "home" and stage == 0) or (room == "market" and stage == 1) or (room == "archive" and stage == 2):
			stage += 1
		elif (room == "market" and stage == 0) or (room == "archive" and stage < 2):
			say("Vuelve con la pista que indica tu objetivo.")
			return
		say(NOTES[room])
	elif k == "consola":
		if stage == 4:
			stage = 5
			spawn_boss()
			say("Vera dejó un mensaje: «Garantizaba que nadie robara el combustible. Ahora nos reconoce a todos como intrusos». CUSTODIO despierta. Libera sus tres seguros mientras esquivas el pulso.")
		else: say("El generador está en línea.")
	elif k.begins_with("seguro") and available(k):
		used[k] = true
		boss.hits = used.size()
		if used.size() == 3:
			stage = 6
			boss.queue_free()
			boss = null
			say("El tercer seguro cae. CUSTODIO se apaga y abre el depósito junto a la máquina.")
	elif k == "cartucho" and stage == 6:
		stage = 7
		say("Has conseguido combustible temporal. La etiqueta de Vera dice: «Alcanza para un solo salto».")
	elif k == "máquina" and stage == 7:
		stage = 8
		jump_to_future()
	refresh()

func jump_to_future():
	jumping = true
	player.set_physics_process(false)
	prompt.text = ""
	route.text = ""
	var flash := create_tween()
	flash.tween_property(curtain,"color:a",1.0,0.65)
	await flash.finished
	enter("arrival",Vector2(175,157))
	say("AÑO 2147 · El suelo tiembla bajo tus pies. Al otro lado del cristal, torres de luz cubren el antiguo parque. El depósito marca cero. Vera te espera junto al ventanal.")
	var fade := create_tween()
	fade.tween_property(curtain,"color:a",0.0,0.65)
	await fade.finished
	jumping = false

func finish_chapter():
	ui.text = "MUNDO 1 COMPLETADO · La cinta de mañana"
	guidance.text = "Primer salto registrado · Nueva Aurora, 2147"
	say("Vera enciende una grabadora: «Dile a tu yo de ayer dónde empieza todo». Repites las palabras que escuchaste en casa. Ahora reconoces hasta la pausa antes de decir Mercado. Vera sella la cinta. «Bienvenido a mañana. Para volver, nos toca encontrar otro cartucho».")
