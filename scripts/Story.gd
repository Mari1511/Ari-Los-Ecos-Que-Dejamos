extends Node
## Toda la historia de "Ari: Los Ecos que Dejamos" (versión RPG): prólogo, 14 capítulos, finales y epílogo.
## Diálogos: ["Ari:triste", "texto"]  -> retrato de Ari con emoción "triste".
## Emociones disponibles en assets/portraits/ (si no existe, se usa _neutral).

const TitleScreen := preload("res://scripts/ui/TitleScreen.gd")
const Epilogue := preload("res://scripts/ui/Epilogue.gd")
const Magnifier := preload("res://scripts/minigames/Magnifier.gd")
const LockPuzzle := preload("res://scripts/minigames/LockPuzzle.gd")
const PlushInspect := preload("res://scripts/minigames/PlushInspect.gd")
const UVDiary := preload("res://scripts/minigames/UVDiary.gd")
const Timeline := preload("res://scripts/minigames/Timeline.gd")

## Cameos de profesores reales: cambia estos nombres SOLO si la persona dio su permiso.
const PROFE_GUARDIA := "Prof. de guardia"
const PROFE_CLASE := "Profesor"

var main

var _ghost = null
var _ghost_cell := Vector2i.ZERO
var _ghost_flag := ""
var _ghost_radius := 5
var _event_running := false
var _in_ending := false

# ================================================================== INICIO

func boot() -> void:
	main.busy = true
	main.in_title = true
	await main.wait(0.5)
	await main.narr("Advertencia de contenido", "void")
	await main.narr("Esta historia trata temas de acoso, abuso de autoridad, manipulación y muerte.", "void")
	await main.narr("Nada se muestra de forma gráfica. Si estos temas te afectan, juega con cuidado y habla con alguien de confianza.", "void")
	main.end_talk()
	to_title()


func to_title() -> void:
	_in_ending = false
	main.busy = true
	main.in_title = true
	main.unload_world()
	main.hud_visible(false)
	main.inventory.close()
	main.end_talk()
	AudioManager.stop_melody()
	AudioManager.set_drone(0.0)
	AudioManager.set_rain(0.5)
	main.fade_rect.color.a = 1.0
	var t: Control = TitleScreen.new()
	main.minigame_holder.add_child(t)
	main.fade_in(1.2)
	var r = await t.finished
	await main.fade_out(1.0)
	t.queue_free()
	if r == "quit":
		get_tree().quit()
		return
	GameState.reset()
	await _prologue()
	await _chapter1()


# ================================================================== PRÓLOGO

func _prologue() -> void:
	AudioManager.set_rain(0.6)
	await main.wait(1.5)
	AudioManager.sfx("buzz", 0.8)
	await main.wait(1.2)
	var ph = main.phone
	for c in ph._list.get_children():
		c.queue_free()
	ph.visible = true
	ph.modulate.a = 0.0
	await main.fade_in(0.1)
	var tw := create_tween()
	tw.tween_property(ph, "modulate:a", 1.0, 1.2)
	await tw.finished
	await ph.message("Ari", "¿Sigues despierto?")
	await ph.message("Edd", "Siempre que me escribes a estas horas, algo pasa.")
	await ph.message("Ari", "¿Puedo preguntarte algo raro?")
	await ph.message("Edd", "Tú nunca preguntas nada normal.")
	await ph.message("Ari", "Si algún día te digo que estoy mal de verdad... ¿me creerías?")
	await ph.message("Edd", "Claro que sí, tonta. ¿Qué clase de pregunta es esa?")
	await ph.message("Ari", "Nada. Olvídalo. Buenas noches, Edd.")
	await main.wait(1.0)
	ph._typing.text = "Ari está escribiendo..."
	await main.wait(2.5)
	ph._typing.text = ""
	AudioManager.sfx("wrong", 0.6)
	ph.system("⚠ Mensaje no enviado")
	await ph.wait_press()
	var tw2 := create_tween()
	tw2.tween_property(ph, "modulate:a", 0.0, 1.5)
	await tw2.finished
	ph.visible = false
	await main.narr("Edd nunca lo vio.", "void")
	main.end_talk()
	await main.wait(1.0)


# ================================================================== CAPÍTULO 1

func _chapter1() -> void:
	main.busy = true
	main.fade_rect.color.a = 1.0
	await main.card("ARI: LOS ECOS QUE DEJAMOS", "", 2.0)
	await main.card("CAPÍTULO 1", "EL ÚLTIMO DÍA", 1.5)
	await main.narr("Varias semanas después.", "void")
	AudioManager.sfx("buzz", 0.8)
	await main.wait(1.2)
	await main.say("Edd", "¿Hola?")
	await main.narr("No escuchamos lo que le dicen.", "void")
	AudioManager.sfx("heartbeat", 1.0)
	await main.say("Edd:miedo", "...")
	await main.narr("Universidad Tecnológica Valle Niebla. Edificio B. Noche.", "void")
	await main.narr("La universidad está cerrada y ha comenzado a llover. La familia de Ari le pidió a Edd que recogiera sus pertenencias.", "void")
	main.end_talk()
	await main.goto_map("auditorio", Vector2i(11, 12), 3, false)
	main.in_title = false
	main.hud_visible(true)
	AudioManager.set_drone(0.25)
	var profe = main.spawn("profe1", Vector2i(13, 11), 1)
	await main.fade_in(1.5)
	await main.lines([
		[PROFE_GUARDIA, "Mercer. La familia de Valen avisó que vendrías."],
		[PROFE_GUARDIA, "El edificio B está cerrado por la tormenta. Las luces fallan desde la tarde."],
		[PROFE_GUARDIA, "Tómate tu tiempo. Estaré en la caseta de vigilancia."],
		["Edd:triste", "Gracias, profe."],
	])
	main.end_talk()
	await profe.walk_to(Vector2i(13, 12), 0.3)
	profe.face(0)
	await profe.fade_out(0.6)
	main.remove_actor(profe)
	AudioManager.sfx("door", 0.5)
	await main.say("Edd:serio", "Solo recojo sus cosas y me voy.")
	AudioManager.play_melody(0.12)
	await main.narr("Desde el pasillo llega una canción. La canción que Ari siempre escuchaba.")
	await main.narr("(Flechas o WASD para moverte · Z/E para examinar · X/TAB para ver objetos)")
	main.end_talk()
	GameState.set_flag("ch1")
	_refresh_map()
	main.busy = false


# ================================================================== EVENTOS POR PASO / FRAME

func tick(_delta: float) -> void:
	if main.map == null or main.player == null:
		return
	if GameState.flag("ch1") and not GameState.flag("music_gone"):
		if main.map.id == "pasillo":
			AudioManager.melody_target = 0.15 + 0.45 * clampf(main.player.cell.x / 18.0, 0.0, 1.0)
		elif main.map.id != "auditorio":
			GameState.set_flag("music_gone")
			AudioManager.stop_melody()


func on_step(c: Vector2i) -> void:
	if _event_running or _in_ending:
		return
	if main.map.id == "pasillo" and GameState.flag("ch1") and not GameState.flag("music_gone") and c.x >= 18:
		_run_event("music")
	elif _ghost != null and is_instance_valid(_ghost):
		var d: Vector2i = c - _ghost_cell
		if absi(d.x) + absi(d.y) <= _ghost_radius:
			_run_event("ghost")


func _run_event(which: String) -> void:
	_event_running = true
	main.busy = true
	if which == "music":
		await _music_vanish()
	else:
		await _ghost_vanish()
	main.end_talk()
	main.busy = false
	_event_running = false


func _music_vanish() -> void:
	GameState.set_flag("music_gone")
	AudioManager.melody_target = 0.0
	AudioManager.stop_melody()
	main.map.lights_on = false
	AudioManager.sfx("static", 0.8)
	await main.wait(0.8)
	main.map.lights_on = true
	await main.say("Edd:miedo", "¿Ari...?")
	await main.say("Edd:triste", "...No. Estoy cansado, eso es todo.")
	await main.say("Edd:serio", "Su salón era el B-204. Empecemos por ahí.")


func _spawn_ghost(c: Vector2i, flag: String, radius := 5) -> void:
	if GameState.flag(flag):
		return
	_ghost = main.spawn("ari_ghost", c, 0)
	_ghost.modulate.a = 0.0
	_ghost.fade_in(2.0)
	_ghost_cell = c
	_ghost_flag = flag
	_ghost_radius = radius


func _ghost_vanish() -> void:
	GameState.set_flag(_ghost_flag)
	var g = _ghost
	_ghost = null
	main.player.face_towards(g.cell)
	AudioManager.sfx("static", 1.0)
	main.lightning()
	await g.fade_out(0.25)
	main.remove_actor(g)
	match _ghost_flag:
		"ghost_pasillo":
			await main.say("Edd:miedo", "...")
			await main.say("Edd:miedo", "Había alguien ahí. Con un abrigo rojo.")
		"ghost_biblioteca":
			await main.say("Edd:miedo", "Estaba junto a la mesa del fondo. Como si me esperara.")
		"ghost_azotea":
			await main.say("Edd:triste", "Ari...")


# ================================================================== MAPAS

func on_map_loaded(id: String) -> void:
	_ghost = null
	_refresh_map()
	if _in_ending:
		return
	match id:
		"pasillo":
			if GameState.flag("ch2") and not GameState.flag("ch7"):
				_spawn_ghost(Vector2i(38, 5), "ghost_pasillo", 5)
		"biblioteca":
			if GameState.flag("ch10") and not GameState.flag("ch11"):
				_spawn_ghost(Vector2i(19, 9), "ghost_biblioteca", 5)
		"azotea":
			if not GameState.flag("ch12"):
				_spawn_ghost(Vector2i(13, 6), "ghost_azotea", 4)


func _available(key: String) -> bool:
	var f := GameState.flag
	match key:
		"aula/pupitre": return not f.call("ch2")
		"aula/mochila": return f.call("ch2") and not f.call("ch3")
		"aula/tablon": return f.call("ch2") and not f.call("ch4")
		"aula/estante": return f.call("ch2") and not f.call("ch5")
		"pasillo/casillero": return f.call("ch2") and not GameState.has_item("linterna")
		"biblioteca/estanteria": return f.call("ch2") and not f.call("ch7")
		"bodega/cajas": return f.call("ch8") and not f.call("ch9")
		"direccion/archivero": return f.call("ch8") and not f.call("ch10")
		"biblioteca/mesa_fondo": return f.call("ch10") and not f.call("ch11")
		"azotea/baranda": return f.call("ch11") and not f.call("ch12")
	return false


func _refresh_map() -> void:
	var m = main.map
	if m == null:
		return
	m.glints.clear()
	for h in m.hotspots:
		m.glints[h.id] = _available(m.id + "/" + h.id)
	m.extra.clear()
	match m.id:
		"aula":
			m.extra["liston_pupitre"] = not GameState.has_item("liston")
		"pasillo":
			m.extra["puerta_dir_abierta"] = GameState.flag("ch8")
		"biblioteca":
			m.extra["escondite_abierto"] = GameState.flag("ch7")
			m.extra["diario_mesa"] = GameState.flag("ch10") and not GameState.has_item("diario")
		"direccion":
			m.extra["archivero_abierto"] = GameState.flag("ch10")


func _pickup(id: String) -> void:
	GameState.add_item(id)
	AudioManager.sfx("pickup", 1.0)
	await main.narr("Obtuviste: " + GameState.ITEMS[id].name)


## Celda libre junto a Edd para que aparezca alguien en un recuerdo.
func _beside() -> Vector2i:
	var p: Vector2i = main.player.cell
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(2, 0), Vector2i(-2, 0)]:
		if not main.is_blocked(p + d):
			return p + d
	return p + Vector2i(1, 0)


func _face_each_other(a, b) -> void:
	a.face_towards(b.cell)
	b.face_towards(a.cell)


# ================================================================== INTERACCIONES

func on_hotspot(map_id: String, h: Dictionary) -> void:
	var key: String = map_id + "/" + h.id
	match key:
		"auditorio/escenario": await main.say("Edd:triste", "\"BIENVENIDOS\". Aquí fue la bienvenida de primer semestre. Ari se durmió en la tercera fila.")
		"pasillo/casillero": await _casillero()
		"pasillo/ventanal": await main.say("Edd:serio", "Se ve la cancha bajo la lluvia. Ari decía que de noche el bosque parecía un mar.")
		"aula/pizarron": await main.say("Edd:serio", "Fórmulas a medio borrar. Alguien escribió \"Bienvenidos de nuevo\" y lo dejó incompleto.")
		"aula/pupitre": await _ch2_liston()
		"aula/mochila": await _ch3_peluche()
		"aula/tablon": await _ch4_foto()
		"aula/estante": await _ch5_reproductor()
		"biblioteca/mesa_dibujo":
			await main.say("Edd:triste", "Aquí dibujaba edificios. Decía que algún día diseñaría uno con una azotea solo para nosotros.")
		"biblioteca/estanteria": await _ch7_candado()
		"biblioteca/mesa_fondo": await _ch11_diario()
		"bodega/herramientas": await main.say("Edd:serio", "Herramientas de mantenimiento. Huele a óxido y a humedad.")
		"bodega/cajas": await _ch9_cuchillo()
		"direccion/escritorio": await _escritorio()
		"direccion/archivero": await _ch10_claudia()
		"azotea/baranda": await _ch12_azotea()
	main.end_talk()
	_refresh_map()


func on_door(d: Dictionary) -> void:
	var target: String = d.target
	if target == "salida":
		await _salida()
		main.end_talk()
		return
	if not GameState.flag("ch1"):
		return
	if not GameState.flag("ch2") and target != "aula" and target != "pasillo":
		await main.say("Edd:serio", "Primero, su salón. El B-204.")
		return
	if target == "direccion" and not GameState.flag("ch8"):
		AudioManager.sfx("door", 0.5)
		await main.say("Edd:serio", "Dirección de carrera. Cerrada con llave.")
		return
	if target == "azotea":
		if not GameState.flag("ch11"):
			await main.say("Edd:triste", "La azotea... Todavía no. Siento que hay algo que no he visto.")
			return
		if not GameState.has_item("reproductor"):
			await main.say("Edd:serio", "Ari nunca subía sin su reproductor. Debería estar en su salón.")
			return
	if target == "direccion" and not GameState.flag("dir_seen"):
		GameState.set_flag("dir_seen")
		await main.say("Edd:miedo", "La puerta está entreabierta. Antes estaba cerrada...")
	main.end_talk()
	var dir := 0
	match String(d.dir):
		"up": dir = 3
		"down": dir = 0
		"left": dir = 1
		"right": dir = 2
	await main.goto_map(target, Vector2i(int(d.spawn[0]), int(d.spawn[1])), dir)


func _salida() -> void:
	if not GameState.flag("ch2"):
		await main.say("Edd:serio", "Todavía no. Les prometí a sus padres que recogería sus cosas.")
		return
	var i: int = await main.choice("¿Irte de la universidad? La historia terminará aquí.", ["Quedarme", "Irme"])
	if i == 1:
		await _ending("oscuro")


func _escritorio() -> void:
	await main.say("Edd:serio", "Una placa: \"Mtra. Helena Duarte — Dirección de carrera\".")
	if GameState.flag("ch10"):
		await main.say("Edd:enojado", "El libro de registro está abierto. La página de esa fecha fue arrancada y reemplazada.")


# ---------------------------------------------------------------- CAPÍTULO 2

func _ch2_liston() -> void:
	if GameState.flag("ch2"):
		await main.say("Edd:triste", "Su lugar. Todavía tiene edificios dibujados en la paleta.")
		return
	await main.chapter("CAPÍTULO 2", "EL LISTÓN")
	await main.say("Edd:triste", "Este era su favorito...")
	main.map.extra["liston_pupitre"] = false
	await _pickup("liston")
	await main.narr("Al tocarlo, comienza un recuerdo.")
	main.end_talk()
	await main.memory("happy")
	await main.narr("14 de marzo. Primer semestre. El primer día que hablaron.", "memory")
	main.focus_cell(Vector2i(11, 6))
	var pl = main.player
	pl.place(Vector2i(10, 7), 2)
	var profe = main.spawn("profe2", Vector2i(4, 5), 0)
	var ari = main.spawn("ari", Vector2i(12, 7), 1)
	await ari.fade_in(0.6)
	await main.say(PROFE_CLASE, "Mercer, busque un lugar. Empezamos.", "memory")
	await main.lines([
		["Edd", "¿Está ocupado?"],
		["Ari", "Sí."],
		["Edd:feliz", "Ah, perfecto. Me encantan los lugares ocupados."],
		["Ari:enojada", "¿Siempre eres así de molesto?"],
		["Edd:feliz", "Solo cuando alguien tiene cara de necesitar un amigo."],
		["Ari:triste", "¿Y si no necesito uno?"],
		["Edd:feliz", "Entonces te molestaré hasta que cambies de opinión."],
		["Ari:sonrojada", "Eres un idiota."],
		["Edd:feliz", "Pero un idiota constante."],
		["Ari:rie", "..."],
		["", "Años después, Edd le regaló aquel listón. Ari decía que era su accesorio favorito."],
	], "memory")
	await main.narr("El recuerdo cambia.", "dark")
	main.end_talk()
	pl.visible = false
	main.remove_actor(profe)
	await main.memory("dark")
	ari.place(Vector2i(11, 7), 0)
	var dam = main.spawn("damian", Vector2i(10, 7), 2)
	var vera = main.spawn("vera", Vector2i(12, 7), 1)
	var nico = main.spawn("nico", Vector2i(13, 5), 0)
	for s in [dam, vera, nico]:
		s.fade_in(0.5)
	AudioManager.set_drone(0.7)
	await main.lines([
		["Damián:burla", "Miren quién llegó."],
		["Vera:burla", "Otra vez con ese horrible listón."],
		["Ari:enojada", "Devuélvemelo."],
	], "dark")
	main.shake(2.0, 0.3)
	AudioManager.sfx("static", 1.0)
	await main.narr("Damián se lo quita. Nico lo graba todo.", "dark")
	await main.say("Nico:miedo", "...", "dark")
	await main.say("Ari:llora", "Ya basta.", "dark")
	main.end_talk()
	await _end_memory()
	await main.say("Edd:triste", "...Nunca me contó esto.")
	await main.say("Edd:llora", "Ni una sola vez.")
	GameState.set_flag("ch2")


func _end_memory() -> void:
	await main.fade_out(0.6)
	main.clear_actors()
	main.player.visible = true
	main.follow()
	AudioManager.set_drone(0.25)
	await main.memory("off", 0.1)
	await main.fade_in(0.6)


# ---------------------------------------------------------------- CAPÍTULO 3

func _ch3_peluche() -> void:
	if GameState.flag("ch3"):
		if not GameState.has_clue("nota_peluche"):
			var i: int = await main.choice("¿Revisar el peluche otra vez?", ["Sí", "No"])
			if i == 0:
				await _inspect_plush()
			return
		await main.say("Edd:triste", "Su mochila. Todavía huele a su perfume.")
		return
	await main.chapter("CAPÍTULO 3", "EL PELUCHE")
	await main.say("Edd:triste", "Un peluche... Uno de los regalos que le hice.")
	await _pickup("peluche")
	main.end_talk()
	await main.memory("happy")
	var ari = main.spawn("ari", _beside(), 0)
	_face_each_other(main.player, ari)
	await ari.fade_in(0.5)
	await main.lines([
		["Edd:feliz", "Es para el peluche. Tú solo tienes que cuidarlo."],
		["Ari:sonrojada", "Eres un idiota."],
		["Edd:feliz", "Ya me lo habías dicho."],
		["Ari:rie", "..."],
		["", "Ari lo abraza y sonríe."],
	], "memory")
	main.end_talk()
	await _end_memory()
	GameState.set_flag("ch3")
	await main.say("Edd:serio", "Tiene una pequeña abertura...")
	await _inspect_plush()


func _inspect_plush() -> void:
	var found = await main.run_minigame(PlushInspect)
	if found:
		GameState.add_clue("nota_peluche")
		await main.say("", "¿Todavía quieres que todos sepan la verdad?", "note")
		await main.narr("La letra no parece de Ari.")
		AudioManager.sfx("heartbeat", 1.0)
		await main.say("Edd:miedo", "Esto no era un recuerdo bonito... era una amenaza.")
	else:
		await main.say("Edd:triste", "...Mejor no lo rompo más.")


# ---------------------------------------------------------------- CAPÍTULO 4

func _ch4_foto() -> void:
	if GameState.flag("ch4"):
		if not GameState.has_clue("lupa_foto"):
			var i: int = await main.choice("¿Mirar la fotografía otra vez con la lupa?", ["Sí", "No"])
			if i == 0:
				await _inspect_photo()
			return
		await main.say("Edd:serio", "Avisos viejos de servicio social. Ya no hay nada aquí.")
		return
	await main.chapter("CAPÍTULO 4", "LA FOTOGRAFÍA")
	await main.say("Edd:feliz", "Somos nosotros. Ese día fue bueno...")
	await main.say("Edd:triste", "¿...no?")
	await _pickup("fotografia")
	await main.narr("En el escritorio del profesor hay una lupa.")
	GameState.set_flag("ch4")
	await _inspect_photo()


func _inspect_photo() -> void:
	var found = await main.run_minigame(Magnifier)
	if found:
		GameState.add_clue("lupa_foto")
		AudioManager.sfx("heartbeat", 1.0)
		await main.say("Edd:miedo", "¿Desde cuándo...?")
		await main.narr("Mientras Edd creía vivir un momento feliz con Ari, ella estaba siendo observada y ridiculizada.")
	else:
		await main.say("Edd:serio", "Solo es una foto. ...¿Verdad?")


# ---------------------------------------------------------------- CAPÍTULO 5

func _ch5_reproductor() -> void:
	if GameState.flag("ch5"):
		await main.say("Edd:serio", "Libros de cálculo y hojas sueltas. Nada más.")
		return
	await main.chapter("CAPÍTULO 5", "EL REPRODUCTOR")
	await main.say("Edd:feliz", "Su viejo reproductor. Todavía tiene las canciones que compartíamos.")
	await _pickup("reproductor")
	main.end_talk()
	AudioManager.play_melody(0.45)
	await main.wait(3.0)
	await main.say("Edd:serio", "Esta pista no es una canción...")
	AudioManager.stop_melody()
	AudioManager.sfx("static", 1.0)
	await main.lines([
		["Damián", "¿Todavía está aquí?"],
		["Nico", "Está en el salón."],
		["Ari", "Déjenme tranquila."],
	], "recording")
	AudioManager.sfx("static", 1.0)
	await main.narr("La grabación termina abruptamente.")
	await main.say("Edd:miedo", "Hay otra grabación.")
	await main.lines([
		["Ari", "No sé cómo explicarlo sin que parezca que estoy exagerando."],
		["Ari", "Él dice que todo es culpa mía."],
		["Ari", "Que si alguien se entera, van a pensar que yo lo provoqué."],
		["Ari", "Que nadie va a creerme porque es un profesor y yo soy una alumna."],
	], "recording")
	AudioManager.sfx("heartbeat", 1.0)
	await main.say("Edd:miedo", "...¿Un profesor?")
	GameState.set_flag("ch5")


# ---------------------------------------------------------------- CAPÍTULO 6

func _casillero() -> void:
	if not GameState.flag("ch2"):
		await main.say("Edd:triste", "Su casillero. Tiene una pegatina de mariquita. Primero iré a su salón.")
		return
	if GameState.has_item("linterna"):
		await main.say("Edd:triste", "Su casillero. Ya está vacío.")
		return
	await main.chapter("CAPÍTULO 6", "EL BROCHE")
	await main.say("Edd:triste", "Un imperdible... el que usé para arreglar su abrigo.")
	await _pickup("broche")
	main.end_talk()
	await main.memory("happy")
	var ari = main.spawn("ari", _beside(), 0)
	_face_each_other(main.player, ari)
	await ari.fade_in(0.5)
	await main.lines([
		["Ari:triste", "Se rompió."],
		["Edd:miedo", "¿Cómo?"],
		["Ari", "Nada."],
		["Edd:serio", "Ari."],
		["Ari:feliz", "Me atoré con una puerta."],
	], "memory")
	await main.narr("El recuerdo cambia.", "dark")
	main.end_talk()
	main.player.visible = false
	await main.memory("dark")
	ari.face(0)
	var dam = main.spawn("damian", ari.cell + Vector2i(-1, 0), 2)
	var vera = main.spawn("vera", ari.cell + Vector2i(1, 0), 1)
	dam.fade_in(0.4)
	vera.fade_in(0.4)
	AudioManager.set_drone(0.7)
	main.shake(2.0, 0.3)
	AudioManager.sfx("static", 1.0)
	await main.say("Damián:burla", "¿A dónde tan rápido?", "dark")
	await main.narr("No fue una puerta. Alguien jaló su abrigo hasta romperlo.", "dark")
	await main.say("Ari:llora", "...", "dark")
	await main.narr("Ari ocultó el verdadero motivo.", "dark")
	main.end_talk()
	await _end_memory()
	GameState.set_flag("ch6")
	await main.say("Edd:llora", "Me mintió... para que no me preocupara.")
	await main.say("Edd:serio", "Hay algo más al fondo del casillero.")
	await main.say("Edd:triste", "Su linterna ultravioleta. Escribía mensajes que solo se veían con esta luz.")
	await _pickup("linterna")
	if GameState.has_item("diario"):
		await main.say("Edd:serio", "El diario... \"No todo se puede ver\".")
		await _try_uv()


# ---------------------------------------------------------------- CAPÍTULO 7 Y 8

func _ch7_candado() -> void:
	if GameState.flag("ch7"):
		await main.say("Edd:triste", "Nuestro escondite. Ya no queda nada adentro.")
		return
	if not GameState.flag("ch2"):
		await main.say("Edd:serio", "Libros de arquitectura. Los favoritos de Ari.")
		return
	await main.say("Edd:serio", "Los libros de arquitectura... Detrás estaba nuestro escondite.")
	await main.narr("Una pequeña caja con un candado. Tiene una estrella dibujada: el símbolo de los dos.")
	var ok = await main.run_minigame(LockPuzzle)
	if not ok:
		await main.say("Edd:serio", "\"Nuestro día\"... ¿Qué fecha era?")
		return
	await main.chapter("CAPÍTULO 7", "EL CANDADO")
	await _pickup("candado")
	await main.narr("Dentro hay fotografías, notas, una pulsera, entradas de cine...")
	await main.say("Edd:feliz", "Todo lo que guardamos juntos.")
	await main.narr("Debajo hay algo más: reportes, capturas de pantalla, fechas, fragmentos de conversaciones.")
	await main.say("Edd:miedo", "¿Qué es todo esto...?")
	await main.say("DENUNCIA", "Yo, Ari Valen, denuncio el acoso constante que he sufrido por parte de mis compañeros: Damián Cross, Vera Salcedo y Nico Ferrer.", "note")
	AudioManager.sfx("heartbeat", 1.0)
	await main.say("DENUNCIA", "También denuncio al Profesor Esteban Rivas.", "note")
	main.shake(2.5, 0.4)
	await main.say("Edd:miedo", "...¿Rivas?")
	GameState.set_flag("ch7")
	main.end_talk()
	await _ch8_rivas()


func _ch8_rivas() -> void:
	await main.chapter("CAPÍTULO 8", "ESTEBAN RIVAS")
	await main.say("Edd:serio", "Rivas. Uno de los profesores más respetados de la carrera. Todos lo admiraban.")
	await main.narr("Ahora aparecen recuerdos que Edd nunca había visto.")
	main.end_talk()
	main.player.visible = false
	await main.memory("dark", 1.5)
	var c := Vector2i(16, 4)
	main.focus_cell(c)
	var ari = main.spawn("ari", c + Vector2i(-2, 0), 2)
	var rivas = main.spawn("rivas", c + Vector2i(2, 0), 1)
	ari.fade_in(0.8)
	await rivas.fade_in(1.2)
	AudioManager.set_drone(1.0)
	await main.lines([
		["Rivas", "Después de todo lo que he hecho por ti..."],
		["Ari:enojada", "Yo nunca le pedí que hiciera nada por mí."],
		["Rivas:sombra", "Piensa bien en lo que estás diciendo."],
		["Ari:miedo", "Quiero irme."],
	], "dark")
	main.end_talk()
	ari.face(1)
	rivas.walk_to(c + Vector2i(1, 0), 0.6)
	await main.fade_out(2.0)
	main.clear_actors()
	await main.wait(1.0)
	await main.lines([
		["Ari", "Quiero que deje de hacerlo."],
		["Ari", "Quiero entrar a clase sin sentir miedo de que me esté esperando."],
	], "void")
	main.end_talk()
	main.player.visible = true
	main.follow()
	AudioManager.set_drone(0.35)
	await main.memory("off", 0.1)
	await main.fade_in(1.0)
	await main.say("Edd:llora", "Ari...")
	await main.say("Edd:enojado", "¿Por qué nadie hizo nada?")
	AudioManager.sfx("door", 0.6)
	await main.narr("A lo lejos, en el pasillo, una puerta se abre.")
	GameState.set_flag("ch8")


# ---------------------------------------------------------------- CAPÍTULO 9

func _ch9_cuchillo() -> void:
	if not GameState.flag("ch8"):
		await main.say("Edd:serio", "Cajas de mantenimiento. Nada que ver con Ari... creo.")
		return
	if GameState.flag("ch9"):
		if not GameState.has_clue("fechas_cuchillo"):
			var i: int = await main.choice("¿Revisar otra vez la etiqueta del cuchillo?", ["Sí", "No"])
			if i == 0:
				await _knife_question()
			return
		await main.say("Edd:serio", "Ya no hay nada aquí.")
		return
	await main.chapter("CAPÍTULO 9", "EL CUCHILLO")
	await main.say("Edd:miedo", "Un cuchillo... envuelto en una sudadera como la de Ari.")
	await _pickup("cuchillo")
	await main.narr("Junto a él hay notas: \"Lo haré el viernes 28\". Todo parece indicar que Ari planeaba enfrentarse a alguien.")
	await main.say("Edd:triste", "No... Ari no haría eso. ¿O sí?")
	GameState.set_flag("ch9")
	await _knife_question()


func _knife_question() -> void:
	await main.say("ETIQUETA", "MANTENIMIENTO — Inventario #07\nRetirado de la bodega: 2 de diciembre.", "note")
	await main.narr("Los últimos días de Ari fueron a finales de noviembre.")
	var i: int = await main.choice("¿Qué significa esto?", ["Ari lo tenía planeado.", "Las fechas no encajan.", "No lo sé."])
	if i == 1:
		GameState.add_clue("fechas_cuchillo")
		await main.say("Edd:serio", "El cuchillo salió de la bodega el 2 de diciembre. Para entonces, Ari ya no estaba.")
		await main.say("Edd:enojado", "Nunca fue suyo. Alguien lo puso aquí.")
		await main.narr("Era una pista falsa, pensada para llevar la investigación hacia una conclusión equivocada.")
	else:
		await main.say("Edd:triste", "No sé qué pensar... pero algo no me cuadra.")


# ---------------------------------------------------------------- CAPÍTULO 10

func _ch10_claudia() -> void:
	if not GameState.flag("ch8"):
		await main.say("Edd:serio", "Un archivero metálico.")
		return
	if GameState.flag("ch10"):
		await main.say("Edd:serio", "El cajón donde estaba la carpeta de Claudia.")
		return
	await main.chapter("CAPÍTULO 10", "CLAUDIA")
	main.map.extra["archivero_abierto"] = true
	await main.say("Edd:serio", "Una carpeta... firmada por Claudia Montes. Se sentaba detrás de Ari.")
	await _pickup("carpeta")
	await main.lines([
		["Claudia:triste", "No te voy a pedir que me perdones."],
		["Claudia:llora", "Solo quiero que esta vez alguien la escuche."],
	])
	await main.narr("Claudia había intentado ayudar a Ari. Dentro hay una copia de la denuncia, con sello de recibido.")
	await main.narr("La denuncia sí fue presentada. Pero nunca llegó a una investigación formal.")
	await main.narr("La directora Helena Duarte recibió el documento. Después, el registro fue modificado.")
	await main.say("Edd:enojado", "La recibieron... y la escondieron.")
	GameState.set_flag("ch10")
	AudioManager.sfx("door", 0.5)
	await main.narr("Algo cae en la biblioteca.")


# ---------------------------------------------------------------- CAPÍTULO 11

func _ch11_diario() -> void:
	if not GameState.flag("ch10"):
		await main.say("Edd:serio", "Una mesa vacía.")
		return
	if GameState.flag("ch11"):
		if GameState.has_item("linterna") and not GameState.has_clue("uv_diario"):
			var i: int = await main.choice("¿Revisar el diario con la linterna UV?", ["Sí", "No"])
			if i == 0:
				await _try_uv()
			return
		await main.say("Edd:triste", "Aquí estaba su diario.")
		return
	await main.chapter("CAPÍTULO 11", "EL DIARIO")
	await main.say("Edd:miedo", "Su diario. No estaba aquí antes... ¿o sí?")
	main.map.extra["diario_mesa"] = false
	await _pickup("diario")
	await main.narr("Está lleno de recuerdos, fechas, dibujos, canciones y fotografías.")
	await main.narr("Casi todo habla de cosas felices: Edd, su familia, sus sueños, los edificios que quería dibujar.")
	await main.say("Edd:feliz", "Me dibujó con el casco de vaca. Qué tonta...")
	await main.narr("En una página vacía aparece una sola frase:")
	await main.say("", "No todo se puede ver.", "note")
	GameState.set_flag("ch11")
	if GameState.has_item("linterna"):
		await main.say("Edd:serio", "La linterna ultravioleta...")
		await _try_uv()
	else:
		await main.say("Edd:serio", "Ari usaba una linterna ultravioleta para sus mensajes secretos. La guardaba en su casillero.")
	await main.say("Edd:serio", "La azotea. Tengo que subir.")


func _try_uv() -> void:
	if not (GameState.has_item("diario") and GameState.has_item("linterna")) or GameState.has_clue("uv_diario"):
		return
	var ok = await main.run_minigame(UVDiary)
	if ok:
		GameState.add_clue("uv_diario")
		await main.say("Edd:llora", "\"No quiero que él se culpe.\"")
		await main.say("Edd:llora", "...Ari.")
	else:
		await main.say("Edd:serio", "Hay algo más escrito... pero no logro leerlo todo.")


# ---------------------------------------------------------------- CAPÍTULOS 12, 13 Y 14

func _ch12_azotea() -> void:
	if GameState.flag("ch12"):
		await main.say("Edd:triste", "La cancha, el bosque, las luces del pueblo. Como si nada hubiera pasado.")
		return
	await main.chapter("CAPÍTULO 12", "LA AZOTEA")
	await main.say("Edd:triste", "Aquí pasábamos las tardes.")
	main.end_talk()
	await main.memory("happy", 1.5)
	AudioManager.set_rain(0.0)
	main.rain.intensity = 0.0
	var pl = main.player
	pl.place(Vector2i(12, 5), 2)
	main.focus_cell(Vector2i(13, 6))
	var ari = main.spawn("ari", Vector2i(14, 5), 1)
	await ari.fade_in(0.8)
	await main.lines([
		["Edd", "Puedes contarme cualquier cosa, ¿sabes?"],
		["Ari:triste", "¿Y si cambia la forma en que me ves?"],
		["Edd:feliz", "Pues te veré de otra forma. Pero seguiré viéndote a ti."],
		["Ari:rie", "Eres muy malo consolando a la gente."],
		["Edd:feliz", "Y aun así sigues viniendo conmigo."],
		["Ari:sonrojada", "Porque eres mi persona favorita para no hablar de nada."],
	], "memory")
	AudioManager.sfx("buzz", 0.8)
	ari.face(0)
	await main.narr("El teléfono de Ari vibra. En la pantalla: RIVAS.", "memory")
	await main.say("Ari:miedo", "...", "memory")
	await main.narr("Su sonrisa desaparece.", "memory")
	await main.say("Edd", "¿Todo bien?", "memory")
	await main.say("Ari:feliz", "Sí.", "memory")
	main.end_talk()
	await ari.walk_path([Vector2i(14, 8), Vector2i(3, 8), Vector2i(3, 12)], 0.22)
	await ari.fade_out(0.6)
	await main.narr("Edd la despide sin saber que sería uno de sus últimos recuerdos juntos.", "memory")
	main.end_talk()
	await main.fade_out(1.0)
	main.clear_actors()
	pl.place(Vector2i(13, 5), 3)
	main.follow()
	await main.memory("off", 0.1)
	AudioManager.set_rain(0.9)
	main.rain.intensity = 1.0
	GameState.set_flag("ch12")
	await main.card("CAPÍTULO 13", "LA ÚLTIMA GRABACIÓN", 1.6)
	await main.fade_in(1.0)
	await main.narr("Hay un último archivo en el reproductor. La fecha coincide con los últimos días de Ari.")
	AudioManager.sfx("static", 0.8)
	await main.lines([
		["Ari", "Hola, Edd."],
		["Ari", "No sé si algún día escucharás esto."],
		["Ari", "Hay cosas que me han pasado y que no sé cómo contarte."],
		["Ari", "Algunas veces siento que, si digo las palabras en voz alta, se volverán más reales."],
		["Ari", "Me han hecho creer que yo tengo la culpa."],
		["Ari", "Que debí comportarme de otra manera."],
		["Ari", "Pero no quiero seguir pensando así."],
		["Ari", "No quiero que todo lo que soy quede reducido a lo que me hicieron."],
		["Ari", "Fui tu amiga. Fui una hija. Fui una chica que se reía de tus chistes malos."],
		["Ari", "Fui muchas cosas antes de tener miedo. Y sigo siendo todas ellas."],
		["Ari", "No te culpes por no haber leído mi mente, Edd."],
		["Ari", "Solo... escucha cuando alguien te diga que no está bien."],
	], "recording")
	AudioManager.sfx("static", 0.8)
	await main.narr("La grabación termina.")
	await main.say("Edd:llora", "Lo siento.")
	await main.say("Edd:llora", "Ojalá hubiera preguntado una vez más.")
	main.end_talk()
	await main.fade_out(1.0)
	await main.fade_in(0.3)
	await main.run_minigame(Timeline)
	await main.narr("Cada objeto representa una parte diferente de Ari.")
	await main.narr("Cada recuerdo feliz muestra quién era ella. Cada revelación muestra lo que estaba ocultando.")
	await main.narr("Lo importante no es lo que le pasó. Es descubrir por qué nadie la escuchó cuando todavía podían hacerlo.")
	await _ending(GameState.ending())


# ================================================================== FINALES

func _ending(kind: String) -> void:
	_in_ending = true
	main.busy = true
	main.end_talk()
	main.hud_visible(false)
	await main.fade_out(1.5)
	AudioManager.set_drone(0.0)
	match kind:
		"verdadero":
			await main.lines([
				["", "Edd reúne las pruebas."],
				["Claudia:triste", "Voy a declarar. Esta vez no me voy a quedar callada."],
				["Nico:llora", "Yo... yo grabé esos videos. Participé en las burlas. Lo siento."],
				["", "La manipulación de los documentos sale a la luz."],
				["", "La investigación sobre Rivas comienza."],
			], "void")
			main.end_talk()
			await main.goto_map("azotea", Vector2i(13, 9), 3, false)
			main.hud_visible(false)
			AudioManager.set_rain(0.3)
			main.rain.intensity = 0.3
			await main.fade_in(1.5)
			await main.player.walk_to(Vector2i(13, 5), 0.32)
			main.player.face(3)
			main.map.extra["liston_baranda"] = true
			AudioManager.sfx("pickup", 0.6)
			await main.narr("Edd coloca el listón de Ari sobre la baranda.")
			await main.say("Edd:llora", "No pude salvarte.")
			await main.say("Edd:triste", "Pero esta vez sí te escuché.")
			main.end_talk()
			await main.fade_out(4.0)
			AudioManager.play_melody(0.35)
			await main.say("Ari", "Fui muchas cosas antes de tener miedo.", "void")
			main.end_talk()
			await main.card("FINAL VERDADERO", "La voz de Ari", 3.0)
			AudioManager.stop_melody()
		"incompleto":
			await main.lines([
				["", "Edd descubre que Ari había intentado pedir ayuda. También descubre el papel de Rivas."],
				["", "Pero algunas pruebas desaparecieron."],
				["", "No puede demostrar toda la cadena de acontecimientos. La versión oficial continúa siendo ambigua."],
				["", "Una página del diario permanece completamente en blanco."],
			], "void")
			await main.say("", " ", "note")
			await main.narr("\"A veces descubrir la verdad no significa poder demostrarla.\"", "void")
			main.end_talk()
			await main.card("FINAL INCOMPLETO", "Lo que quedó oculto", 3.0)
		_:
			main.end_talk()
			await main.goto_map("pasillo", Vector2i(8, 5), 1, false)
			main.hud_visible(false)
			await main.fade_in(1.0)
			await main.player.walk_to(Vector2i(1, 5), 0.3)
			await main.fade_out(1.2)
			main.unload_world()
			await main.lines([
				["", "Edd abandona la universidad."],
				["", "La versión oficial permanece intacta. Los rumores continúan."],
				["", "Los nombres de quienes hicieron daño desaparecen lentamente de los registros."],
				["", "Las clases vuelven a empezar. Los estudiantes regresan."],
			], "void")
			main.end_talk()
			await main.goto_map("aula", Vector2i(2, 11), 3, false)
			main.hud_visible(false)
			main.player.visible = false
			main.canvas_mod.color = Color(0.9, 0.9, 0.95)
			main.map.extra["liston_pupitre"] = true
			main.map.glints.clear()
			AudioManager.set_rain(0.0)
			var s = main.spawn("profe2", Vector2i(15, 7), 1)
			s.sprite.modulate = Color(0.25, 0.22, 0.28)
			main.focus_cell(Vector2i(11, 6))
			await main.fade_in(1.0)
			await s.walk_to(Vector2i(11, 7), 0.35)
			s.face(0)
			await main.narr("En un salón, alguien encuentra un pequeño listón...")
			main.map.extra["liston_pupitre"] = false
			await s.walk_to(Vector2i(9, 4), 0.35)
			s.face(3)
			await main.narr("...y lo tira a la basura.")
			main.end_talk()
			main.fade_rect.color.a = 1.0
			main.unload_world()
			await main.wait(2.0)
			AudioManager.sfx("buzz", 0.9)
			await main.wait(1.2)
			await main.say("Ari", "¿Sigues despierto?", "void")
			main.end_talk()
			await main.card("FIN", "El silencio continúa", 3.0)
	await _epilogue()


func _epilogue() -> void:
	main.unload_world()
	main.fade_rect.color.a = 1.0
	AudioManager.set_rain(0.2)
	AudioManager.play_melody(0.3)
	var ep: Control = Epilogue.new()
	main.minigame_holder.add_child(ep)
	main.fade_in(1.0)
	await ep.finished
	await main.fade_out(1.0)
	ep.queue_free()
	await main.lines([
		["", "Ari no debe quedar reducida a lo que le ocurrió."],
		["", "Ella era una persona antes de convertirse en un misterio."],
		["", "Una amiga. Una hija. Una estudiante. Una artista. Una chica que tenía sueños."],
		["", "Y alguien que pidió ayuda."],
		["", "El verdadero horror no fue solamente lo que le hicieron."],
		["", "Fue que demasiadas personas tuvieron la oportunidad de escucharla y eligieron no hacerlo."],
	], "void")
	await main.narr("Recuerdos encontrados: %d / 8   ·   Pistas ocultas: %d / 4" % [GameState.evidence_count(), GameState.clues.size()], "void")
	await main.narr("Si tú o alguien que conoces está pasando por algo así, no lo guardes. Habla con alguien de confianza o busca la línea de ayuda de tu país.", "void")
	main.end_talk()
	AudioManager.stop_melody()
	await main.card("ARI: LOS ECOS QUE DEJAMOS", "Gracias por escuchar.", 3.0)
	to_title()
