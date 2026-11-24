extends Control
## Capítulo 3: examinar el peluche. Hay una costura abierta en la espalda con una nota dentro.

signal finished(result)

var _back := false
var _found := false
var _closed := false
var _info: Label
var _canvas: Control
var _t := 0.0
const SEAM := Rect2(600, 330, 80, 60)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.02, 0.03, 0.95)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_plush)
	add_child(_canvas)
	_info = Label.new()
	_info.position = Vector2(0, 60)
	_info.size = Vector2(1280, 30)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info.add_theme_font_size_override("font_size", 20)
	_info.text = "El peluche que le regalé. Está más pesado de lo que recordaba."
	add_child(_info)
	var b1 := Button.new()
	b1.text = "Voltear"
	b1.focus_mode = Control.FOCUS_NONE
	b1.position = Vector2(500, 620)
	b1.size = Vector2(130, 46)
	b1.add_theme_font_size_override("font_size", 20)
	b1.pressed.connect(_flip)
	add_child(b1)
	var b2 := Button.new()
	b2.text = "Dejarlo"
	b2.focus_mode = Control.FOCUS_NONE
	b2.position = Vector2(650, 620)
	b2.size = Vector2(130, 46)
	b2.add_theme_font_size_override("font_size", 20)
	b2.pressed.connect(_finish)
	add_child(b2)


func _flip() -> void:
	_back = not _back
	AudioManager.sfx("step", 0.7)
	if _back and not _found:
		_info.text = "Hay una costura abierta en la espalda..."
	_canvas.queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	_canvas.queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _back and not _found and SEAM.grow(20).has_point(event.position):
			_found = true
			AudioManager.sfx("heartbeat", 1.0)
			_info.text = "Hay un papel doblado adentro."
			get_tree().create_timer(1.2).timeout.connect(_finish)


func _finish() -> void:
	if _closed:
		return
	_closed = true
	finished.emit(_found)


func _draw_plush() -> void:
	var br := Color(0.6, 0.42, 0.3)
	var c := Vector2(640, 380)
	_canvas.draw_circle(c + Vector2(-95, -175), 45, br)
	_canvas.draw_circle(c + Vector2(95, -175), 45, br)
	_canvas.draw_circle(c + Vector2(-95, -175), 25, br.lightened(0.2) if not _back else br.darkened(0.1))
	_canvas.draw_circle(c + Vector2(95, -175), 25, br.lightened(0.2) if not _back else br.darkened(0.1))
	_canvas.draw_circle(c + Vector2(0, -100), 110, br)
	_canvas.draw_circle(c + Vector2(0, 110), 130, br)
	_canvas.draw_circle(c + Vector2(-140, 60), 40, br.darkened(0.08))
	_canvas.draw_circle(c + Vector2(140, 60), 40, br.darkened(0.08))
	_canvas.draw_circle(c + Vector2(-80, 210), 45, br.darkened(0.08))
	_canvas.draw_circle(c + Vector2(80, 210), 45, br.darkened(0.08))
	if not _back:
		_canvas.draw_circle(c + Vector2(-38, -115), 11, Color(0.05, 0.03, 0.03))
		_canvas.draw_circle(c + Vector2(38, -115), 11, Color(0.05, 0.03, 0.03))
		_canvas.draw_circle(c + Vector2(-34, -119), 3, Color(1, 1, 1, 0.8))
		_canvas.draw_circle(c + Vector2(42, -119), 3, Color(1, 1, 1, 0.8))
		_canvas.draw_circle(c + Vector2(0, -70), 34, br.lightened(0.25))
		_canvas.draw_circle(c + Vector2(0, -80), 10, Color(0.25, 0.15, 0.1))
		_canvas.draw_rect(Rect2(c + Vector2(-60, 0), Vector2(120, 22)), Color(0.85, 0.15, 0.2))
	else:
		# costura
		var s := SEAM
		_canvas.draw_rect(s, Color(0.25, 0.15, 0.1) if not _found else Color(0.1, 0.06, 0.04))
		for k in 6:
			var x := s.position.x + 8 + k * 13
			_canvas.draw_line(Vector2(x, s.position.y - 6), Vector2(x + 4, s.end.y + 6), Color(0.9, 0.85, 0.75), 2.0)
		_canvas.draw_line(s.end, s.end + Vector2(30, 20 + sin(_t * 2.0) * 5.0), Color(0.9, 0.85, 0.75), 1.5)
		if _found:
			_canvas.draw_rect(Rect2(s.position + Vector2(18, 8), Vector2(44, 34)), Color(0.92, 0.9, 0.82))
		elif fmod(_t, 2.0) < 1.0:
			_canvas.draw_rect(s.grow(4), Color(1, 0.9, 0.7, 0.15), false, 2.0)
