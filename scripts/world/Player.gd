extends "res://scripts/world/Character.gd"
## Edd: movimiento con teclado casilla por casilla (estilo RPG Maker).

signal bumped(target: Vector2i)
signal stepped(c: Vector2i)

var can_move := false
var blocked_fn: Callable
var _bump_cool := 0.0
var _hold := 0.0


func _ready() -> void:
	setup("edd")
	step_time = 0.2
	# linterna: luz propia alrededor de Edd
	var l := PointLight2D.new()
	l.texture = preload("res://scripts/world/Map.gd").make_light_texture()
	l.texture_scale = 0.55
	l.energy = 0.75
	l.color = Color(0.9, 0.9, 1.0)
	l.position = Vector2(0, -12)
	add_child(l)
	step_finished.connect(func(): stepped.emit(cell))


func _process(delta: float) -> void:
	super._process(delta)
	_bump_cool -= delta
	if not can_move or moving:
		return
	var dir := -1
	if Input.is_action_pressed("move_down"):
		dir = 0
	elif Input.is_action_pressed("move_left"):
		dir = 1
	elif Input.is_action_pressed("move_right"):
		dir = 2
	elif Input.is_action_pressed("move_up"):
		dir = 3
	if dir < 0:
		_hold = 0.0
		return
	# un toque corto solo gira; mantener camina
	if dir != facing and _hold == 0.0:
		face(dir)
		_hold = 0.001
		return
	_hold += delta
	var target: Vector2i = cell + DIRS[dir]
	if step(dir, blocked_fn):
		if randf() < 0.5:
			AudioManager.sfx("step", 0.45)
	elif _bump_cool <= 0.0:
		_bump_cool = 0.35
		bumped.emit(target)

