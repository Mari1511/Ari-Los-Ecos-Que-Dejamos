extends Node2D
## Personaje RPG por casillas con hoja de sprites 3x4 (abajo, izquierda, derecha, arriba), cuadros de 24x32.

const T := 16
const FW := 24
const FH := 32
const DIRS := {0: Vector2i(0, 1), 1: Vector2i(-1, 0), 2: Vector2i(1, 0), 3: Vector2i(0, -1)}

signal step_finished

var char_id := ""
var cell := Vector2i.ZERO
var facing := 0
var moving := false
var step_time := 0.2
var map  # Map.gd (para colisiones)

var sprite: Sprite2D
var _anim_t := 0.0
var _foot := 0
var _ghost := false


func setup(id: String) -> void:
	char_id = id
	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/chars/%s.png" % id)
	sprite.hframes = 3
	sprite.vframes = 4
	sprite.offset = Vector2(0, -FH / 2.0 + 1)
	add_child(sprite)
	_update_frame(1)


func set_ghost(v: bool) -> void:
	_ghost = v
	if v:
		sprite.modulate = Color(0.7, 0.85, 1.3, 0.7)
		var l := PointLight2D.new()
		l.texture = preload("res://scripts/world/Map.gd").make_light_texture()
		l.texture_scale = 0.35
		l.energy = 0.9
		l.color = Color(0.5, 0.7, 1.0)
		l.position = Vector2(0, -16)
		add_child(l)


func place(c: Vector2i, dir := -1) -> void:
	cell = c
	position = Vector2(c.x * T + 8, c.y * T + 16)
	if dir >= 0:
		face(dir)


func face(dir: int) -> void:
	facing = dir
	_update_frame(1)


func face_towards(c: Vector2i) -> void:
	var d := c - cell
	if absi(d.x) > absi(d.y):
		face(2 if d.x > 0 else 1)
	elif d.y != 0:
		face(0 if d.y > 0 else 3)


func _update_frame(col: int) -> void:
	if sprite:
		sprite.frame = facing * 3 + col


func front_cell() -> Vector2i:
	return cell + DIRS[facing]


## Intenta dar un paso. Devuelve false si está bloqueado.
func step(dir: int, blocked_fn: Callable = Callable()) -> bool:
	if moving:
		return false
	face(dir)
	var target: Vector2i = cell + DIRS[dir]
	if blocked_fn.is_valid() and blocked_fn.call(target):
		return false
	moving = true
	cell = target
	_foot = 1 - _foot
	var tw := create_tween()
	tw.tween_property(self, "position", Vector2(target.x * T + 8, target.y * T + 16), step_time)
	_anim_t = 0.0
	_update_frame(0 if _foot == 0 else 2)
	tw.finished.connect(_on_step_done)
	return true


func _on_step_done() -> void:
	moving = false
	_update_frame(1)
	step_finished.emit()


func _process(delta: float) -> void:
	if moving:
		_anim_t += delta
		if _anim_t > step_time * 0.5:
			_update_frame(1)
	if _ghost:
		sprite.position.y = sin(Time.get_ticks_msec() / 400.0) * 1.5 - 1.0


## Camina en línea recta hacia c (primero en X, luego en Y). Ignora colisiones (para escenas).
func walk_to(c: Vector2i, speed := 0.25) -> void:
	var old := step_time
	step_time = speed
	while cell.x != c.x:
		step(2 if c.x > cell.x else 1)
		await step_finished
	while cell.y != c.y:
		step(0 if c.y > cell.y else 3)
		await step_finished
	step_time = old


func walk_path(cells: Array, speed := 0.25) -> void:
	for c in cells:
		await walk_to(c, speed)


func fade_in(t := 0.5) -> void:
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, t)
	await tw.finished


func fade_out(t := 0.5) -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, t)
	await tw.finished
