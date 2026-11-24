extends Control
## Pantalla de título.

signal finished(result)

var _canvas: Control
var _t := 0.0
var _ghost: Texture2D = preload("res://assets/portraits/ari_triste.png")
var _drops: Array = []
var _done := false


func _emit(r: String) -> void:
	if _done or _t < 0.5:
		return
	_done = true
	finished.emit(r)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.01, 0.01, 0.02)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	for i in 160:
		_drops.append(Vector3(randf() * 1400.0, randf() * 720.0, randf_range(0.4, 1.0)))
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_bg)
	add_child(_canvas)
	var t := Label.new()
	t.text = "ARI"
	t.position = Vector2(0, 150)
	t.size = Vector2(1280, 100)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 96)
	t.add_theme_color_override("font_color", Color(0.95, 0.75, 0.78))
	add_child(t)
	var s := Label.new()
	s.text = "LOS ECOS QUE DEJAMOS"
	s.position = Vector2(0, 260)
	s.size = Vector2(1280, 40)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s.add_theme_font_size_override("font_size", 30)
	s.add_theme_color_override("font_color", Color(0.8, 0.8, 0.88))
	add_child(s)
	var g := Label.new()
	g.text = "Horror psicológico · Misterio · Drama"
	g.position = Vector2(0, 305)
	g.size = Vector2(1280, 30)
	g.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	g.add_theme_font_size_override("font_size", 16)
	g.add_theme_color_override("font_color", Color(0.55, 0.55, 0.62))
	add_child(g)
	_button("Comenzar", Vector2(540, 420), _emit.bind("start"))
	_button("Salir", Vector2(540, 480), _emit.bind("quit"))


func _button(text: String, pos: Vector2, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = Vector2(200, 46)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 22)
	b.pressed.connect(cb)
	add_child(b)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_emit("start")


func _process(delta: float) -> void:
	_t += delta
	for i in _drops.size():
		var d: Vector3 = _drops[i]
		d.y += 700.0 * d.z * delta
		d.x -= 120.0 * d.z * delta
		if d.y > 730.0:
			d.y = -20.0
			d.x = randf() * 1400.0
		_drops[i] = d
	_canvas.queue_redraw()


func _draw_bg() -> void:
	var a := 0.10 + 0.08 * sin(_t * 0.7)
	if fmod(_t, 11.0) > 10.7:
		a = 0.35
	var sz := Vector2(_ghost.get_width(), _ghost.get_height()) * 3.0
	_canvas.draw_texture_rect(_ghost, Rect2(Vector2(1040, 720) - Vector2(sz.x / 2, sz.y), sz), false, Color(0.55, 0.7, 1.0, a * 1.6))
	for d in _drops:
		_canvas.draw_line(Vector2(d.x, d.y), Vector2(d.x - 4 * d.z, d.y + 18 * d.z), Color(0.6, 0.65, 0.8, 0.25 * d.z), 1.0)
	_canvas.draw_string(ThemeDB.fallback_font, Vector2(0, 690), "E / Enter para comenzar", HORIZONTAL_ALIGNMENT_CENTER, 1280, 14, Color(0.5, 0.5, 0.55, 0.5 + 0.3 * sin(_t * 2.0)))
