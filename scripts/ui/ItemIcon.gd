extends Control
## Ícono de objeto dibujado por código (64x64 lógico, se escala al tamaño del control).

var item_id := ""
var owned := true
var selected := false


func _ready() -> void:
	resized.connect(queue_redraw)


func set_item(id: String, has: bool) -> void:
	item_id = id
	owned = has
	queue_redraw()


func _draw() -> void:
	var s := minf(size.x, size.y) / 64.0
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.08, 0.1, 0.9))
	draw_rect(Rect2(Vector2.ZERO, size), Color(1, 0.85, 0.5, 0.9) if selected else Color(0.4, 0.4, 0.45, 0.8), false, 2.0)
	draw_set_transform(Vector2((size.x - 64 * s) / 2, (size.y - 64 * s) / 2), 0.0, Vector2(s, s))
	if not owned:
		draw_string(ThemeDB.fallback_font, Vector2(0, 44), "?", HORIZONTAL_ALIGNMENT_CENTER, 64, 36, Color(0.4, 0.4, 0.45))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	match item_id:
		"liston":
			var red := Color(0.85, 0.12, 0.2)
			draw_colored_polygon(PackedVector2Array([Vector2(32, 30), Vector2(10, 18), Vector2(10, 42)]), red)
			draw_colored_polygon(PackedVector2Array([Vector2(32, 30), Vector2(54, 18), Vector2(54, 42)]), red)
			draw_colored_polygon(PackedVector2Array([Vector2(29, 32), Vector2(22, 56), Vector2(28, 54)]), red.darkened(0.2))
			draw_colored_polygon(PackedVector2Array([Vector2(35, 32), Vector2(42, 56), Vector2(36, 54)]), red.darkened(0.2))
			draw_circle(Vector2(32, 30), 5, red.lightened(0.2))
		"peluche":
			var br := Color(0.6, 0.42, 0.3)
			draw_circle(Vector2(20, 16), 7, br)
			draw_circle(Vector2(44, 16), 7, br)
			draw_circle(Vector2(32, 26), 15, br)
			draw_circle(Vector2(32, 48), 14, br)
			draw_circle(Vector2(27, 24), 2, Color.BLACK)
			draw_circle(Vector2(37, 24), 2, Color.BLACK)
			draw_circle(Vector2(32, 30), 3, Color(0.3, 0.2, 0.15))
			draw_line(Vector2(38, 42), Vector2(42, 52), Color(0.2, 0.1, 0.1), 1.5)
		"fotografia":
			draw_rect(Rect2(10, 10, 44, 46), Color(0.92, 0.9, 0.85))
			draw_rect(Rect2(14, 14, 36, 32), Color(0.35, 0.3, 0.4))
			draw_circle(Vector2(26, 30), 6, Color(0.95, 0.55, 0.6))
			draw_circle(Vector2(38, 30), 6, Color(0.9, 0.75, 0.3))
		"reproductor":
			draw_rect(Rect2(18, 8, 28, 48), Color(0.25, 0.25, 0.3))
			draw_rect(Rect2(22, 12, 20, 16), Color(0.5, 0.7, 0.8))
			draw_circle(Vector2(32, 42), 9, Color(0.4, 0.4, 0.45))
			draw_circle(Vector2(32, 42), 3, Color(0.2, 0.2, 0.25))
			draw_line(Vector2(46, 14), Vector2(56, 4), Color(0.9, 0.9, 0.9), 2.0)
		"broche":
			draw_arc(Vector2(18, 32), 8, PI * 0.5, PI * 1.5, 12, Color(0.8, 0.8, 0.85), 3.0)
			draw_line(Vector2(18, 24), Vector2(52, 24), Color(0.8, 0.8, 0.85), 3.0)
			draw_line(Vector2(18, 40), Vector2(48, 40), Color(0.8, 0.8, 0.85), 3.0)
			draw_rect(Rect2(46, 20, 10, 10), Color(0.7, 0.7, 0.75))
		"candado":
			draw_arc(Vector2(32, 24), 12, PI, TAU, 16, Color(0.7, 0.7, 0.72), 5.0)
			draw_rect(Rect2(16, 24, 32, 28), Color(0.75, 0.6, 0.25))
			draw_circle(Vector2(32, 36), 4, Color(0.2, 0.15, 0.05))
			draw_rect(Rect2(30, 38, 4, 8), Color(0.2, 0.15, 0.05))
		"cuchillo":
			draw_colored_polygon(PackedVector2Array([Vector2(12, 50), Vector2(42, 20), Vector2(50, 14), Vector2(46, 24), Vector2(16, 54)]), Color(0.8, 0.82, 0.85))
			draw_line(Vector2(10, 46), Vector2(20, 56), Color(0.3, 0.3, 0.3), 3.0)
			draw_line(Vector2(14, 52), Vector2(6, 60), Color(0.35, 0.2, 0.1), 6.0)
			draw_rect(Rect2(36, 40, 18, 10), Color(0.9, 0.85, 0.5))
		"diario":
			draw_rect(Rect2(14, 8, 36, 48), Color(0.55, 0.2, 0.3))
			draw_rect(Rect2(14, 8, 6, 48), Color(0.4, 0.12, 0.2))
			draw_rect(Rect2(26, 18, 18, 10), Color(0.9, 0.85, 0.75))
			draw_circle(Vector2(38, 44), 4, Color(0.9, 0.2, 0.2))
		"linterna":
			draw_rect(Rect2(12, 26, 30, 12), Color(0.25, 0.25, 0.3))
			draw_rect(Rect2(42, 22, 8, 20), Color(0.35, 0.35, 0.4))
			draw_colored_polygon(PackedVector2Array([Vector2(50, 24), Vector2(62, 14), Vector2(62, 50), Vector2(50, 40)]), Color(0.6, 0.3, 1.0, 0.6))
		"carpeta":
			draw_rect(Rect2(8, 14, 48, 38), Color(0.75, 0.6, 0.35))
			draw_rect(Rect2(8, 10, 20, 6), Color(0.75, 0.6, 0.35))
			draw_line(Vector2(16, 30), Vector2(48, 30), Color(0.3, 0.2, 0.1), 1.5)
			draw_string(ThemeDB.fallback_font, Vector2(14, 46), "C.M.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.2, 0.1, 0.05))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
