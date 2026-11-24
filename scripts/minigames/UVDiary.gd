extends Control
## Capítulo 11: página en blanco del diario + linterna UV. Revelar los 4 mensajes = pista oculta.

signal finished(result)

const PAGE := Rect2(380, 60, 520, 560)
const MESSAGES := [
	{"text": "Intenté decirlo.", "pos": Vector2(470, 190)},
	{"text": "No me escucharon.", "pos": Vector2(560, 300)},
	{"text": "Edd no sabe.", "pos": Vector2(450, 420)},
	{"text": "No quiero que él se culpe.", "pos": Vector2(520, 530)},
]
const RADIUS := 95.0

var _canvas: Control
var _info: Label
var _reveal := []
var _found := []
var _closed := false
var _done := false
var _mouse := Vector2(-999, -999)
var _font: Font


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_font = ThemeDB.fallback_font
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.01, 0.97)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_page)
	add_child(_canvas)
	for m in MESSAGES:
		_reveal.append(0.0)
		_found.append(false)
	_info = Label.new()
	_info.position = Vector2(0, 640)
	_info.size = Vector2(1280, 30)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info.add_theme_font_size_override("font_size", 18)
	_info.text = "Pasa la luz ultravioleta sobre la página."
	add_child(_info)
	var b := Button.new()
	b.text = "Cerrar el diario"
	b.focus_mode = Control.FOCUS_NONE
	b.position = Vector2(1030, 600)
	b.add_theme_font_size_override("font_size", 18)
	b.pressed.connect(_finish)
	add_child(b)


func _process(delta: float) -> void:
	_mouse = get_local_mouse_position()
	var count := 0
	for i in MESSAGES.size():
		var center: Vector2 = MESSAGES[i].pos + Vector2(110, -8)
		if _mouse.distance_to(center) < RADIUS * 0.8:
			_reveal[i] = minf(1.0, _reveal[i] + delta * 0.9)
			if _reveal[i] >= 1.0 and not _found[i]:
				_found[i] = true
				AudioManager.sfx("heartbeat", 0.7)
		if _found[i]:
			count += 1
	if count == MESSAGES.size() and not _done:
		_done = true
		_info.text = "\"No quiero que él se culpe.\""
		get_tree().create_timer(2.5).timeout.connect(_finish)
	_canvas.queue_redraw()


func _draw_page() -> void:
	_canvas.draw_rect(PAGE, Color(0.12, 0.11, 0.1))
	_canvas.draw_rect(PAGE, Color(0.2, 0.18, 0.16), false, 3.0)
	for k in 18:
		_canvas.draw_line(Vector2(PAGE.position.x + 30, PAGE.position.y + 50 + k * 28), Vector2(PAGE.end.x - 30, PAGE.position.y + 50 + k * 28), Color(0.2, 0.22, 0.3, 0.5), 1.0)
	_canvas.draw_string(_font, PAGE.position + Vector2(0, 40), "No todo se puede ver.", HORIZONTAL_ALIGNMENT_CENTER, PAGE.size.x, 20, Color(0.55, 0.5, 0.45))
	# luz UV
	if PAGE.grow(60).has_point(_mouse):
		for r in [RADIUS, RADIUS * 0.75, RADIUS * 0.5]:
			_canvas.draw_circle(_mouse, r, Color(0.45, 0.2, 0.9, 0.12))
	for i in MESSAGES.size():
		var m: Dictionary = MESSAGES[i]
		var center: Vector2 = m.pos + Vector2(110, -8)
		var near := clampf(1.0 - _mouse.distance_to(center) / RADIUS, 0.0, 1.0)
		var a := maxf(near * 0.9, 1.0 if _found[i] else _reveal[i] * 0.5)
		if a > 0.01:
			_canvas.draw_string(_font, m.pos, m.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(0.75, 0.55, 1.0, a))


func _finish() -> void:
	if _closed:
		return
	_closed = true
	finished.emit(_done)
