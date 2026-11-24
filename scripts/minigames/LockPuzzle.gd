extends Control
## Capítulo 7: candado de 4 dígitos del escondite. La pista es la fecha del listón (14 de marzo → 1403).

signal finished(result)

const CODE := [1, 4, 0, 3]

var digits := [0, 0, 0, 0]
var _labels: Array = []
var _info: Label
var _canvas: Control
var _closed := false
var _sel := 0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.03, 0.95)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_lock)
	add_child(_canvas)
	for i in 4:
		var x := 470 + i * 90
		var up := _btn("▲", Vector2(x, 250), _change.bind(i, 1))
		var dn := _btn("▼", Vector2(x, 450), _change.bind(i, -1))
		var l := Label.new()
		l.position = Vector2(x, 320)
		l.size = Vector2(70, 100)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.add_theme_font_size_override("font_size", 64)
		l.add_theme_color_override("font_color", Color(0.15, 0.1, 0.05))
		add_child(l)
		_labels.append(l)
	_btn("Abrir", Vector2(520, 560), _try, Vector2(110, 48))
	_btn("Dejarlo", Vector2(650, 560), _cancel, Vector2(110, 48))
	_info = Label.new()
	_info.position = Vector2(0, 40)
	_info.size = Vector2(1280, 30)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info.add_theme_font_size_override("font_size", 20)
	_info.text = "Nuestra estrella dibujada en el metal. Cuatro números. \"Nuestro día\", decía ella."
	add_child(_info)
	var hint := Label.new()
	hint.position = Vector2(0, 640)
	hint.size = Vector2(1280, 30)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	hint.text = "Ratón o ← → ↑ ↓ para girar · E para abrir · (Revisa el inventario con TAB si no recuerdas)"
	add_child(hint)
	_refresh()


func _btn(t: String, pos: Vector2, cb: Callable, sz := Vector2(70, 50)) -> Button:
	var b := Button.new()
	b.text = t
	b.position = pos
	b.size = sz
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 22)
	b.pressed.connect(cb)
	add_child(b)
	return b


func _change(i: int, d: int) -> void:
	digits[i] = (digits[i] + d + 10) % 10
	_sel = i
	AudioManager.sfx("step", 0.8)
	_refresh()


func _refresh() -> void:
	for i in 4:
		_labels[i].text = str(digits[i])
		_labels[i].modulate = Color(1, 1, 1) if i == _sel else Color(0.75, 0.75, 0.75)
	_canvas.queue_redraw()


func _try() -> void:
	if _closed:
		return
	if digits == CODE:
		_closed = true
		_info.text = "Clic."
		AudioManager.sfx("door", 1.0)
		await get_tree().create_timer(0.8).timeout
		finished.emit(true)
	else:
		AudioManager.sfx("wrong", 1.0)
		_info.text = "No abre. ¿Qué fecha era \"nuestro día\"?"


func _cancel() -> void:
	if _closed:
		return
	_closed = true
	finished.emit(false)


func _input(event: InputEvent) -> void:
	if _closed:
		return
	if event.is_action_pressed("move_left"):
		_sel = (_sel + 3) % 4
		_refresh()
	elif event.is_action_pressed("move_right"):
		_sel = (_sel + 1) % 4
		_refresh()
	elif event.is_action_pressed("move_up"):
		_change(_sel, 1)
	elif event is InputEventKey and event.pressed and not event.echo and (event.physical_keycode == KEY_S or event.physical_keycode == KEY_DOWN):
		_change(_sel, -1)
	elif event.is_action_pressed("interact"):
		_try()
	elif event.is_action_pressed("pause"):
		_cancel()
	else:
		return
	get_viewport().set_input_as_handled()


func _draw_lock() -> void:
	# cuerpo del candado
	_canvas.draw_arc(Vector2(640, 240), 150, PI, TAU, 32, Color(0.55, 0.55, 0.58), 26.0)
	_canvas.draw_rect(Rect2(430, 230, 420, 300), Color(0.72, 0.58, 0.25))
	_canvas.draw_rect(Rect2(430, 230, 420, 300), Color(0.4, 0.3, 0.1), false, 4.0)
	for i in 4:
		_canvas.draw_rect(Rect2(465 + i * 90, 320, 80, 100), Color(0.88, 0.85, 0.75))
	# estrella
	var c := Vector2(640, 500)
	var pts := PackedVector2Array()
	for k in 10:
		var r := 16.0 if k % 2 == 0 else 7.0
		var a := -PI / 2 + k * PI / 5
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	_canvas.draw_colored_polygon(pts, Color(0.35, 0.25, 0.08))
