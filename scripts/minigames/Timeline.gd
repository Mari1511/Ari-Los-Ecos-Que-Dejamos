extends Control
## Capítulo 14: ordenar la línea temporal con las piezas de evidencia.

signal finished(result)

const ItemIcon := preload("res://scripts/ui/ItemIcon.gd")

const EVENTS := [
	{"title": "El acoso de sus compañeros", "items": ["liston", "fotografia", "broche"]},
	{"title": "La manipulación y el abuso de autoridad de Rivas", "items": ["reproductor", "peluche"]},
	{"title": "El intento de pedir ayuda", "items": ["candado"]},
	{"title": "El encubrimiento de la escuela", "items": ["cuchillo"]},
	{"title": "El aislamiento de Ari", "items": ["diario"]},
]

var _slots: Array = []
var _cards: Array = []
var _placed: Array = []
var _info: Label
var _busy := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.03, 0.97)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var head := Label.new()
	head.text = "CAPÍTULO 14 — LA VERDAD"
	head.position = Vector2(0, 18)
	head.size = Vector2(1280, 36)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_theme_font_size_override("font_size", 28)
	head.add_theme_color_override("font_color", Color(0.95, 0.7, 0.72))
	add_child(head)
	# las ocho piezas
	for i in GameState.EVIDENCE.size():
		var ic := ItemIcon.new()
		ic.position = Vector2(232 + i * 104, 66)
		ic.size = Vector2(86, 86)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(ic)
		ic.set_item(GameState.EVIDENCE[i], GameState.has_item(GameState.EVIDENCE[i]))
	# ranuras
	for i in EVENTS.size():
		var p := PanelContainer.new()
		var st := StyleBoxFlat.new()
		st.bg_color = Color(0.07, 0.07, 0.09)
		st.border_color = Color(0.4, 0.4, 0.45)
		st.set_border_width_all(2)
		st.set_corner_radius_all(4)
		st.set_content_margin_all(8)
		p.add_theme_stylebox_override("panel", st)
		p.position = Vector2(40 + i * 244, 190)
		p.custom_minimum_size = Vector2(225, 120)
		p.size = Vector2(225, 120)
		var l := Label.new()
		l.text = str(i + 1)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(205, 100)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.add_theme_font_size_override("font_size", 18)
		l.add_theme_color_override("font_color", Color(0.45, 0.45, 0.5))
		p.add_child(l)
		add_child(p)
		_slots.append(l)
		if i < EVENTS.size() - 1:
			var arrow := Label.new()
			arrow.text = "→"
			arrow.position = Vector2(40 + i * 244 + 224, 232)
			arrow.add_theme_font_size_override("font_size", 22)
			add_child(arrow)
	# tarjetas desordenadas
	var order := [2, 4, 0, 3, 1]
	for k in order.size():
		var i: int = order[k]
		var b := Button.new()
		b.text = EVENTS[i].title + "\n" + _items_text(EVENTS[i].items)
		b.focus_mode = Control.FOCUS_NONE
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.position = Vector2(40 + k * 244, 380)
		b.size = Vector2(225, 130)
		b.add_theme_font_size_override("font_size", 17)
		b.pressed.connect(_pick.bind(i, b))
		add_child(b)
		_cards.append(b)
	_info = Label.new()
	_info.position = Vector2(0, 560)
	_info.size = Vector2(1280, 60)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info.add_theme_font_size_override("font_size", 20)
	_info.text = "Ordena lo que le pasó a Ari, del principio al final. Haz clic en las tarjetas en orden."
	add_child(_info)


func _items_text(ids: Array) -> String:
	var parts: Array = []
	for id in ids:
		parts.append(GameState.ITEMS[id].name.replace("El ", "").replace("La ", "") if GameState.has_item(id) else "???")
	if ids.has("cuchillo"):
		parts.append("Carpeta de Claudia")
	return "(" + ", ".join(parts) + ")"


func _pick(i: int, b: Button) -> void:
	if _busy:
		return
	var slot := _placed.size()
	_placed.append(i)
	b.disabled = true
	b.modulate.a = 0.3
	_slots[slot].text = EVENTS[i].title
	_slots[slot].add_theme_color_override("font_color", Color(0.95, 0.9, 0.85))
	AudioManager.sfx("step", 1.0)
	if i != slot:
		_busy = true
		AudioManager.sfx("wrong", 1.0)
		_slots[slot].add_theme_color_override("font_color", Color(1, 0.35, 0.35))
		_info.text = "Algo no encaja. Piensa en el orden en que ocurrió todo."
		await get_tree().create_timer(1.4).timeout
		_reset()
		_busy = false
		return
	if _placed.size() == EVENTS.size():
		_busy = true
		AudioManager.sfx("pickup", 1.0)
		_info.text = "Primero el acoso. Después Rivas. Luego pidió ayuda... y la escuela lo ocultó. Al final, se quedó sola."
		await get_tree().create_timer(4.0).timeout
		finished.emit(true)


func _reset() -> void:
	_placed.clear()
	for i in _slots.size():
		_slots[i].text = str(i + 1)
		_slots[i].add_theme_color_override("font_color", Color(0.45, 0.45, 0.5))
	for b in _cards:
		b.disabled = false
		b.modulate.a = 1.0
