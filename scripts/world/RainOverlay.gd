extends Control
## Lluvia en pantalla (para la azotea y escenas exteriores).

var intensity := 0.0
var _drops: Array = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in 220:
		_drops.append(Vector3(_rng.randf() * 1400.0, _rng.randf() * 720.0, _rng.randf_range(0.6, 1.0)))


func _process(delta: float) -> void:
	if intensity <= 0.01:
		if visible:
			visible = false
		return
	visible = true
	for i in _drops.size():
		var d: Vector3 = _drops[i]
		d.y += 900.0 * d.z * delta
		d.x -= 160.0 * d.z * delta
		if d.y > 730.0:
			d.y = -20.0
			d.x = _rng.randf() * 1400.0
		_drops[i] = d
	queue_redraw()


func _draw() -> void:
	var n := int(_drops.size() * intensity)
	for i in n:
		var d: Vector3 = _drops[i]
		draw_line(Vector2(d.x, d.y), Vector2(d.x - 5.0 * d.z, d.y + 22.0 * d.z), Color(0.7, 0.75, 0.9, 0.35 * d.z), 1.0)
