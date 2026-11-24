extends Control
## Capítulo 4: observar la fotografía con una lupa. Encontrar a las tres figuras del fondo = pista oculta.

signal finished(result)

const TARGETS := [
	{"name": "Damián", "uv": Vector2(0.05, 0.65)},
	{"name": "Vera", "uv": Vector2(0.13, 0.66)},
	{"name": "Nico", "uv": Vector2(0.21, 0.64)},
]
const SHADER := """
shader_type canvas_item;
uniform sampler2D secret_tex;
uniform vec2 center = vec2(0.5);
uniform float radius = 0.11;
uniform float zoom = 2.2;
void fragment() {
	vec2 d = UV - center;
	float l = length(d);
	if (l < radius) {
		COLOR = texture(secret_tex, center + d / zoom);
		if (l > radius - 0.006) { COLOR = vec4(0.75, 0.62, 0.4, 1.0); }
	} else {
		vec4 c = texture(TEXTURE, UV);
		COLOR = vec4(c.rgb * 0.7, 1.0);
	}
}
"""

var _photo: TextureRect
var _mat: ShaderMaterial
var _found := {}
var _dwell := {}
var _info: Label
var _done := false
var _closed := false
var _overlay: Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.03, 0.96)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	_photo = TextureRect.new()
	_photo.texture = load("res://assets/images/foto.png")
	_photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_photo.position = Vector2(340, 40)
	_photo.size = Vector2(600, 600)
	_mat = ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = SHADER
	_mat.shader = sh
	_mat.set_shader_parameter("secret_tex", load("res://assets/images/foto_secret.png"))
	_photo.material = _mat
	_photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_photo)
	_overlay = Control.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.draw.connect(_draw_overlay)
	add_child(_overlay)
	_info = Label.new()
	_info.position = Vector2(0, 650)
	_info.size = Vector2(1280, 30)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info.add_theme_font_size_override("font_size", 18)
	_info.text = "Mueve la lupa con el ratón. Observa con atención el fondo."
	add_child(_info)
	var b := Button.new()
	b.text = "Dejar la fotografía"
	b.focus_mode = Control.FOCUS_NONE
	b.position = Vector2(1020, 600)
	b.add_theme_font_size_override("font_size", 18)
	b.pressed.connect(_finish)
	add_child(b)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	var m := get_local_mouse_position()
	var uv := (m - _photo.position) / _photo.size
	uv = uv.clamp(Vector2.ZERO, Vector2.ONE)
	_mat.set_shader_parameter("center", uv)
	for t in TARGETS:
		if _found.has(t.name):
			continue
		if uv.distance_to(t.uv) < 0.05:
			_dwell[t.name] = _dwell.get(t.name, 0.0) + delta
			if _dwell[t.name] > 0.7:
				_found[t.name] = true
				AudioManager.sfx("heartbeat", 1.0)
				_info.text = "Ahí... ¿%s?   (%d / 3)" % [t.name, _found.size()]
				_overlay.queue_redraw()
		else:
			_dwell[t.name] = 0.0
	if _found.size() == TARGETS.size() and not _done:
		_done = true
		_info.text = "Damián, Vera y Nico. Riéndose. Señalándola."
		get_tree().create_timer(2.2).timeout.connect(_finish)


func _draw_overlay() -> void:
	for t in TARGETS:
		if _found.has(t.name):
			var p: Vector2 = _photo.position + t.uv * _photo.size
			_overlay.draw_arc(p, 26, 0, TAU, 24, Color(0.9, 0.15, 0.2, 0.9), 2.0)
			_overlay.draw_string(ThemeDB.fallback_font, p + Vector2(-40, -32), t.name, HORIZONTAL_ALIGNMENT_CENTER, 80, 15, Color(1, 0.4, 0.4))


func _finish() -> void:
	if _closed:
		return
	_closed = true
	set_process(false)
	finished.emit(_found.size() == TARGETS.size())
