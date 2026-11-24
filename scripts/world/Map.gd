extends Node2D
## Mapa por casillas (16x16). Fondo pixel art pre-renderizado + capa superior + colisiones de maps.json.
## Los mapas se generan con tools/maps.py a partir de las fotos de referencia de la universidad.

const T := 16
const OUTDOOR := ["azotea"]
const AMBIENT := {
	"auditorio": Color(0.30, 0.30, 0.42),
	"pasillo": Color(0.27, 0.28, 0.40),
	"aula": Color(0.28, 0.28, 0.40),
	"biblioteca": Color(0.24, 0.22, 0.32),
	"bodega": Color(0.16, 0.16, 0.22),
	"direccion": Color(0.26, 0.22, 0.28),
	"azotea": Color(0.42, 0.44, 0.62),
}

static var _db := {}

var id := ""
var w := 0
var h := 0
var title := ""
var hotspots: Array = []
var doors: Array = []
var spawns := {}
var glints := {}
var lights_on := true
var outdoor := false
var ambient := Color(0.3, 0.3, 0.4)
var extra := {}  # objetos visibles extra: {"liston_baranda": true, ...}

var _collision: Array = []
var _lamps: Array = []
var _t := 0.0
var _flash := 0.0
var _deco: Node2D


static func db() -> Dictionary:
	if _db.is_empty():
		var f := FileAccess.open("res://assets/maps/maps.json", FileAccess.READ)
		_db = JSON.parse_string(f.get_as_text())
	return _db


func setup(map_id: String) -> void:
	id = map_id
	var d: Dictionary = db()[map_id]
	w = int(d.w)
	h = int(d.h)
	title = d.title
	hotspots = d.hotspots
	doors = d.doors
	spawns = d.spawns
	_collision = d.collision
	outdoor = OUTDOOR.has(map_id)
	ambient = AMBIENT.get(map_id, Color(0.3, 0.3, 0.4))
	var bg := Sprite2D.new()
	bg.texture = load("res://assets/maps/%s.png" % map_id)
	bg.centered = false
	bg.z_index = -10
	add_child(bg)
	var over := Sprite2D.new()
	over.texture = load("res://assets/maps/%s_over.png" % map_id)
	over.centered = false
	over.z_index = 50
	add_child(over)
	_deco = Node2D.new()
	_deco.z_index = -5
	_deco.draw.connect(_draw_deco)
	add_child(_deco)
	for l in d.lights:
		var pl := PointLight2D.new()
		pl.texture = make_light_texture()
		pl.position = Vector2(l[0] * T + 8, l[1] * T + 8)
		pl.texture_scale = 0.75
		pl.energy = 0.95
		pl.color = Color(1.0, 0.94, 0.8)
		add_child(pl)
		_lamps.append(pl)
	if outdoor:
		for i in 3:
			var pl := PointLight2D.new()
			pl.texture = make_light_texture()
			pl.position = Vector2(w * T * (0.2 + 0.3 * i), 60)
			pl.texture_scale = 1.6
			pl.energy = 0.35
			pl.color = Color(0.7, 0.75, 1.0)
			add_child(pl)


static func make_light_texture() -> GradientTexture2D:
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	g.add_point(0.45, Color(1, 1, 1, 0.5))
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 256
	t.height = 256
	return t


func size_px() -> Vector2:
	return Vector2(w * T, h * T)


func is_blocked(c: Vector2i) -> bool:
	if c.x < 0 or c.y < 0 or c.x >= w or c.y >= h:
		return true
	return String(_collision[c.y])[c.x] == "1"


func hotspot_at(c: Vector2i):
	for hs in hotspots:
		if int(hs.x) == c.x and int(hs.y) == c.y:
			return hs
	return null


func door_at(c: Vector2i):
	for d in doors:
		if int(d.x) == c.x and int(d.y) == c.y:
			return d
	return null


static func cell_to_pos(c: Vector2i) -> Vector2:
	return Vector2(c.x * T + 8, c.y * T + 16)


func lightning() -> void:
	_flash = 1.0


func _process(delta: float) -> void:
	_t += delta
	_flash = maxf(0.0, _flash - delta * 2.5)
	for i in _lamps.size():
		var l: PointLight2D = _lamps[i]
		var base := 0.95 if lights_on else 0.0
		var flick := 1.0
		if i % 3 == 1 or id == "bodega":
			var n := sin(_t * 23.0 + i * 7.0) * sin(_t * 3.1 + i)
			if n > 0.8:
				flick = 0.1
			elif fmod(_t + i * 1.7, 9.0) < 0.25:
				flick = 0.3 if fmod(_t * 20.0, 1.0) < 0.5 else 1.0
		l.energy = base * flick
		l.visible = l.energy > 0.01
	_deco.queue_redraw()


func _draw_deco() -> void:
	# destellos de objetos pendientes
	for hs in hotspots:
		if glints.get(hs.id, false):
			var p := Vector2(int(hs.x) * T + 8, int(hs.y) * T + 6)
			var a := 0.45 + 0.45 * sin(_t * 3.5 + p.x)
			_deco.draw_rect(Rect2(p - Vector2(1, 1), Vector2(2, 2)), Color(1, 0.95, 0.75, a))
			_deco.draw_line(p + Vector2(-4, 0), p + Vector2(4, 0), Color(1, 0.95, 0.75, a * 0.6), 1.0)
			_deco.draw_line(p + Vector2(0, -4), p + Vector2(0, 4), Color(1, 0.95, 0.75, a * 0.6), 1.0)
	# objetos de la historia
	if extra.get("liston_pupitre", false):
		_deco.draw_rect(Rect2(11 * T + 4, 8 * T + 4, 7, 3), Color(0.85, 0.12, 0.2))
	if extra.get("diario_mesa", false):
		_deco.draw_rect(Rect2(17 * T + 4, 9 * T + 3, 9, 7), Color(0.55, 0.2, 0.3))
		_deco.draw_rect(Rect2(17 * T + 4, 9 * T + 3, 2, 7), Color(0.4, 0.12, 0.2))
	if extra.get("liston_baranda", false):
		var bx := 13 * T + 5
		_deco.draw_rect(Rect2(bx, 4 * T + 2, 6, 3), Color(0.9, 0.15, 0.2))
		_deco.draw_line(Vector2(bx + 1, 4 * T + 5), Vector2(bx + sin(_t * 2.0) * 1.5, 4 * T + 11), Color(0.9, 0.15, 0.2), 1.0)
		_deco.draw_line(Vector2(bx + 5, 4 * T + 5), Vector2(bx + 6 + sin(_t * 2.3) * 1.5, 4 * T + 10), Color(0.9, 0.15, 0.2), 1.0)
	if extra.get("archivero_abierto", false):
		_deco.draw_rect(Rect2(12 * T + 1, 2 * T + 1, 14, 5), Color(0.08, 0.08, 0.1))
	if extra.get("escondite_abierto", false):
		_deco.draw_rect(Rect2(16 * T + 3, 2 * T + 2, 10, 6), Color(0.05, 0.03, 0.02))
	if extra.get("puerta_dir_abierta", false):
		_deco.draw_rect(Rect2(30 * T + 2, 1 * T + 5, 12, 27), Color(0.05, 0.04, 0.03, 0.85))
	# lluvia de la azotea en el mundo (charcos que salpican)
	if outdoor:
		for k in 14:
			var x := fmod(k * 97.3 + _t * 13.0, w * T)
			var y := 5 * T + fmod(k * 53.1, (h - 6) * T)
			var r := fmod(_t * 2.0 + k * 0.37, 1.0) * 4.0
			_deco.draw_arc(Vector2(x, y), r, 0, TAU, 8, Color(0.7, 0.8, 1.0, 0.4 * (1.0 - r / 4.0)), 1.0)
	# relámpago en ventanas
	if _flash > 0.0:
		_deco.draw_rect(Rect2(0, 0, w * T, 3 * T), Color(0.8, 0.85, 1.0, _flash * 0.25))
