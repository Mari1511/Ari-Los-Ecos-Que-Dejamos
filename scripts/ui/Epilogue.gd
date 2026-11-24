extends Control
## Epílogo: fotografías de Ari. Las escenas se dibujan con su sprite;
## puedes reemplazar cada una por una ilustración real (ver PHOTOS / "tex").

signal finished(result)

const PHOTOS := [
	{"caption": "riendo", "scene": "pink", "sprite": "res://assets/portraits/ari_rie.png"},
	{"caption": "dibujando", "scene": "desk", "sprite": "res://assets/portraits/ari_feliz.png"},
	{"caption": "escuchando música", "scene": "music", "sprite": "res://assets/portraits/ari_sonrojada.png"},
	{"caption": "con Edd", "tex": "res://assets/images/foto_clean.png"},
	{"caption": "comiendo", "scene": "lunch", "sprite": "res://assets/portraits/ari_rie.png"},
	{"caption": "en la universidad", "scene": "school", "sprite": "res://assets/portraits/ari_neutral.png"},
	{"caption": "en su habitación", "scene": "room", "sprite": "res://assets/portraits/ari_feliz.png"},
	{"caption": "mirando la ciudad", "scene": "city", "sprite": "res://assets/images/ari_back.png"},
]
const FRAME := Rect2(440, 90, 400, 480)
const PHOTO := Rect2(465, 115, 350, 350)

var _canvas: Control
var _idx := 0
var _alpha := 0.0
var _rot := 0.0
var _tex: Texture2D
var _skip := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.03)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_photo)
	add_child(_canvas)
	_run()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or (event is InputEventMouseButton and event.pressed):
		_skip = true
		get_viewport().set_input_as_handled()


func _run() -> void:
	await get_tree().create_timer(0.6).timeout
	for i in PHOTOS.size():
		_idx = i
		_rot = randf_range(-0.05, 0.05)
		var p: Dictionary = PHOTOS[i]
		_tex = load(p.get("tex", p.get("sprite", "")))
		var tw := create_tween()
		tw.tween_property(self, "_alpha", 1.0, 0.8)
		await tw.finished
		_skip = false
		var t := 0.0
		while t < 3.2 and not _skip:
			await get_tree().process_frame
			t += get_process_delta_time()
		var tw2 := create_tween()
		tw2.tween_property(self, "_alpha", 0.0, 0.6)
		await tw2.finished
	finished.emit(true)


func _process(_d: float) -> void:
	_canvas.queue_redraw()


func _draw_photo() -> void:
	if _tex == null:
		return
	var c := FRAME.get_center()
	_canvas.draw_set_transform(c, _rot, Vector2.ONE)
	var off := -c
	var a := _alpha
	_canvas.draw_rect(Rect2(FRAME.position + off + Vector2(8, 10), FRAME.size), Color(0, 0, 0, 0.5 * a))
	_canvas.draw_rect(Rect2(FRAME.position + off, FRAME.size), Color(0.95, 0.93, 0.88, a))
	var pr := Rect2(PHOTO.position + off, PHOTO.size)
	var p: Dictionary = PHOTOS[_idx]
	if p.has("tex"):
		_canvas.draw_texture_rect(_tex, pr, false, Color(1, 1, 1, a))
	else:
		_scene(p.scene, pr, a)
		var h := pr.size.y * (0.78 if p.scene == "city" else 0.92)
		var w := h * _tex.get_width() / _tex.get_height()
		var sx := pr.get_center().x - w / 2
		if p.scene == "city":
			sx = pr.position.x + 40
		_canvas.draw_texture_rect(_tex, Rect2(sx, pr.end.y - h - (6 if p.scene == "city" else 0), w, h), false, Color(1, 1, 1, a))
	# tono cálido de foto vieja
	_canvas.draw_rect(pr, Color(1.0, 0.85, 0.6, 0.12 * a))
	_canvas.draw_string(ThemeDB.fallback_font, Vector2(FRAME.position.x, FRAME.end.y - 40) + off, "Ari, " + p.caption, HORIZONTAL_ALIGNMENT_CENTER, FRAME.size.x, 26, Color(0.25, 0.2, 0.25, a))
	_canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _scene(kind: String, r: Rect2, a: float) -> void:
	match kind:
		"pink":
			_canvas.draw_rect(r, Color(0.95, 0.75, 0.75, a))
			for k in 12:
				_canvas.draw_circle(r.position + Vector2(fmod(k * 73.0, r.size.x), fmod(k * 41.0, r.size.y * 0.6)), 6, Color(1, 0.9, 0.92, a * 0.8))
		"desk":
			_canvas.draw_rect(r, Color(0.55, 0.6, 0.7, a))
			_canvas.draw_rect(Rect2(r.position.x, r.end.y - 90, r.size.x, 90), Color(0.5, 0.35, 0.22, a))
			_canvas.draw_rect(Rect2(r.end.x - 130, r.end.y - 120, 100, 70), Color(0.95, 0.95, 0.9, a))
			for k in 4:
				_canvas.draw_rect(Rect2(r.end.x - 120 + k * 22, r.end.y - 110 + k * 6, 16, 50 - k * 6), Color(0.2, 0.2, 0.25, a), false, 1.5)
		"music":
			_canvas.draw_rect(r, Color(0.3, 0.3, 0.5, a))
			for k in 6:
				var p := r.position + Vector2(30 + k * 55, 40 + fmod(k * 37.0, 80.0))
				_canvas.draw_circle(p, 7, Color(1, 0.85, 0.95, a))
				_canvas.draw_line(p + Vector2(6, 0), p + Vector2(6, -26), Color(1, 0.85, 0.95, a), 2.0)
		"lunch":
			_canvas.draw_rect(r, Color(0.8, 0.75, 0.6, a))
			_canvas.draw_rect(Rect2(r.position.x, r.end.y - 70, r.size.x, 70), Color(0.6, 0.45, 0.3, a))
			_canvas.draw_rect(Rect2(r.position.x + 20, r.end.y - 90, 80, 40), Color(0.85, 0.2, 0.25, a))
			_canvas.draw_circle(Vector2(r.position.x + 45, r.end.y - 75), 10, Color(1, 1, 1, a))
		"school":
			_canvas.draw_rect(r, Color(0.45, 0.55, 0.55, a))
			for k in 7:
				_canvas.draw_rect(Rect2(r.position.x + k * 50, r.position.y + 100, 46, 200), Color(0.3, 0.45, 0.5, a))
		"room":
			_canvas.draw_rect(r, Color(0.7, 0.6, 0.75, a))
			_canvas.draw_rect(Rect2(r.position.x + 20, r.position.y + 30, 70, 90), Color(0.3, 0.3, 0.45, a))
			_canvas.draw_rect(Rect2(r.end.x - 110, r.position.y + 40, 80, 60), Color(0.95, 0.9, 0.8, a))
			_canvas.draw_rect(Rect2(r.position.x, r.end.y - 60, r.size.x, 60), Color(0.5, 0.4, 0.5, a))
		"city":
			_canvas.draw_rect(r, Color(0.1, 0.1, 0.22, a))
			for k in 10:
				var bh := 60.0 + fmod(k * 53.0, 140.0)
				_canvas.draw_rect(Rect2(r.position.x + k * 36, r.end.y - bh - 40, 32, bh), Color(0.05, 0.05, 0.12, a))
				_canvas.draw_rect(Rect2(r.position.x + k * 36 + 10, r.end.y - bh - 20, 5, 5), Color(1, 0.85, 0.5, a))
			_canvas.draw_rect(Rect2(r.position.x, r.end.y - 40, r.size.x, 40), Color(0.15, 0.15, 0.18, a))
		_:
			_canvas.draw_rect(r, Color(0.5, 0.5, 0.5, a))
