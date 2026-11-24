extends Node
## Motor del juego estilo RPG: mapa por casillas, cámara, UI, transiciones y utilidades para Story.gd.

const MapScene := preload("res://scripts/world/Map.gd")
const PlayerScript := preload("res://scripts/world/Player.gd")
const CharacterScript := preload("res://scripts/world/Character.gd")
const RainOverlay := preload("res://scripts/world/RainOverlay.gd")
const DialogueBox := preload("res://scripts/ui/DialogueBox.gd")
const ChoiceBox := preload("res://scripts/ui/ChoiceBox.gd")
const Inventory := preload("res://scripts/ui/Inventory.gd")
const PhoneChat := preload("res://scripts/ui/PhoneChat.gd")
const Story := preload("res://scripts/Story.gd")

const ZOOM := 3.0
const VIEW := Vector2(1280, 720)

const FX_SHADER := """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float sepia = 0.0;
uniform float redness = 0.0;
uniform float vignette = 0.65;
uniform float grain = 0.045;
uniform float aberr = 0.0;
float rnd(vec2 co) { return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453); }
void fragment() {
	vec2 suv = SCREEN_UV;
	vec3 c;
	c.r = texture(screen_tex, suv + vec2(aberr, 0.0)).r;
	c.g = texture(screen_tex, suv).g;
	c.b = texture(screen_tex, suv - vec2(aberr, 0.0)).b;
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(c, vec3(l * 1.08 + 0.06, l * 0.92 + 0.03, l * 0.7), sepia);
	c = mix(c, vec3(l * 1.3 + 0.05, l * 0.2, l * 0.25), redness);
	float v = smoothstep(0.25, 0.85, length((UV - 0.5) * vec2(1.3, 1.0)));
	c *= 1.0 - v * vignette;
	c += (rnd(floor(UV * vec2(426.0, 240.0)) + fract(TIME * 7.0)) - 0.5) * grain;
	COLOR = vec4(c, 1.0);
}
"""

var world: Node2D
var entities: Node2D
var canvas_mod: CanvasModulate
var camera: Camera2D
var map
var player
var actors: Array = []

var rain
var fx_mat: ShaderMaterial
var dialogue
var choice_box
var inventory
var phone
var minigame_holder: Control
var hud_prompt: Label
var hud_room: Label
var hud_hint: Label
var fade_rect: ColorRect
var card_title: Label
var card_sub: Label

var story
var busy := true
var in_title := true
var _cool := 0.0
var _focus = null
var _thunder_t := 20.0


func _ready() -> void:
	world = Node2D.new()
	add_child(world)
	canvas_mod = CanvasModulate.new()
	canvas_mod.color = Color(0.3, 0.3, 0.4)
	world.add_child(canvas_mod)
	entities = Node2D.new()
	entities.y_sort_enabled = true
	world.add_child(entities)
	camera = Camera2D.new()
	camera.zoom = Vector2(ZOOM, ZOOM)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	world.add_child(camera)
	camera.make_current()

	var rain_layer := CanvasLayer.new()
	rain_layer.layer = 3
	add_child(rain_layer)
	rain = RainOverlay.new()
	rain_layer.add_child(rain)

	var fx_layer := CanvasLayer.new()
	fx_layer.layer = 4
	add_child(fx_layer)
	var fx := ColorRect.new()
	fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_mat = ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = FX_SHADER
	fx_mat.shader = sh
	fx.material = fx_mat
	for p in ["sepia", "redness", "aberr"]:
		fx_mat.set_shader_parameter(p, 0.0)
	fx_layer.add_child(fx)

	var ui := CanvasLayer.new()
	ui.layer = 10
	add_child(ui)
	hud_prompt = _make_label(20, Color(1, 0.92, 0.75))
	hud_prompt.position = Vector2(0, 676)
	hud_prompt.size = Vector2(1280, 30)
	ui.add_child(hud_prompt)
	hud_room = _make_label(18, Color(0.85, 0.85, 0.92, 0.9))
	hud_room.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	hud_room.position = Vector2(20, 14)
	ui.add_child(hud_room)
	hud_hint = _make_label(14, Color(0.6, 0.6, 0.66, 0.8))
	hud_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hud_hint.position = Vector2(860, 16)
	hud_hint.size = Vector2(400, 20)
	hud_hint.text = "Flechas/WASD mover · Z/E examinar · X/TAB objetos"
	ui.add_child(hud_hint)
	minigame_holder = Control.new()
	minigame_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	minigame_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(minigame_holder)
	phone = PhoneChat.new()
	phone.visible = false
	ui.add_child(phone)
	inventory = Inventory.new()
	ui.add_child(inventory)

	var fade_layer := CanvasLayer.new()
	fade_layer.layer = 20
	add_child(fade_layer)
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_layer.add_child(fade_rect)
	card_title = _make_label(44, Color(0.95, 0.9, 0.9))
	card_title.position = Vector2(0, 290)
	card_title.size = Vector2(1280, 60)
	card_title.modulate.a = 0.0
	fade_layer.add_child(card_title)
	card_sub = _make_label(26, Color(0.85, 0.5, 0.56))
	card_sub.position = Vector2(0, 365)
	card_sub.size = Vector2(1280, 40)
	card_sub.modulate.a = 0.0
	fade_layer.add_child(card_sub)

	var top := CanvasLayer.new()
	top.layer = 25
	add_child(top)
	dialogue = DialogueBox.new()
	top.add_child(dialogue)
	choice_box = ChoiceBox.new()
	top.add_child(choice_box)

	story = Story.new()
	story.main = self
	add_child(story)
	hud_visible(false)
	story.boot()


func _make_label(size: int, col: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("shadow_offset_x", 2)
	l.add_theme_constant_override("shadow_offset_y", 2)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.size = Vector2(1280, 30)
	return l


func hud_visible(v: bool) -> void:
	hud_prompt.visible = v
	hud_room.visible = v
	hud_hint.visible = v


# ------------------------------------------------------------------ BUCLE

func _process(delta: float) -> void:
	_cool -= delta
	if map == null or player == null:
		return
	_update_camera()
	_thunder_t -= delta
	if _thunder_t <= 0.0:
		_thunder_t = randf_range(25.0, 50.0)
		lightning()
	story.tick(delta)
	var free: bool = not busy and not inventory.visible
	player.can_move = free
	hud_prompt.text = ""
	if not free:
		return
	var fc: Vector2i = player.front_cell()
	var hs = map.hotspot_at(fc)
	var door = map.door_at(fc)
	if hs != null:
		hud_prompt.text = "[Z] Examinar: %s" % hs.label
	elif door != null:
		hud_prompt.text = "[Z] Ir a: %s" % door.label
	if _cool <= 0.0 and not player.moving and Input.is_action_just_pressed("interact"):
		if hs != null:
			_run("hs", hs)
		elif door != null:
			_run("door", door)


func _update_camera() -> void:
	var target: Vector2 = player.position + Vector2(0, -8) if _focus == null else _focus
	var half := VIEW / ZOOM / 2.0
	var ms: Vector2 = map.size_px()
	var x := ms.x / 2.0 if ms.x <= half.x * 2.0 else clampf(target.x, half.x, ms.x - half.x)
	var y := ms.y / 2.0 if ms.y <= half.y * 2.0 else clampf(target.y, half.y, ms.y - half.y)
	camera.position = Vector2(x, y)


func _on_bump(target: Vector2i) -> void:
	if busy or map == null:
		return
	var door = map.door_at(target)
	if door != null:
		_run("door", door)


func _on_step(c: Vector2i) -> void:
	if not busy:
		story.on_step(c)


func _run(kind: String, data: Dictionary) -> void:
	busy = true
	hud_prompt.text = ""
	if kind == "hs":
		await story.on_hotspot(map.id, data)
	else:
		await story.on_door(data)
	dialogue.hide_box()
	busy = false
	_cool = 0.25


func _unhandled_input(event: InputEvent) -> void:
	if in_title or map == null:
		return
	if event.is_action_pressed("inventory"):
		if inventory.visible:
			inventory.close()
		elif not busy:
			inventory.open()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause") and not busy:
		if inventory.visible:
			inventory.close()
			return
		_pause_menu()


func _pause_menu() -> void:
	busy = true
	var i := await choice("Pausa", ["Continuar", "Volver al título", "Salir del juego"])
	if i == 1:
		await fade_out(0.8)
		story.to_title()
		return
	elif i == 2:
		get_tree().quit()
	busy = false
	_cool = 0.2


# ------------------------------------------------------------------ API PARA LA HISTORIA

func wait(t: float) -> void:
	await get_tree().create_timer(t).timeout


func say(speaker: String, text: String, style := "") -> void:
	await dialogue.say(speaker, text, style)


func narr(text: String, style := "") -> void:
	await dialogue.say("", text, style)


## arr = [["Ari:feliz", "texto"], ["", "narración"], ...]
func lines(arr: Array, style := "") -> void:
	for l in arr:
		await dialogue.say(l[0], l[1], l[2] if l.size() > 2 else style)


func end_talk() -> void:
	dialogue.hide_box()


func choice(prompt: String, options: Array) -> int:
	dialogue.hide_box()
	return await choice_box.ask(prompt, options)


func fade_out(t := 0.8) -> void:
	var tw := create_tween()
	tw.tween_property(fade_rect, "color:a", 1.0, t)
	await tw.finished


func fade_in(t := 0.8) -> void:
	var tw := create_tween()
	tw.tween_property(fade_rect, "color:a", 0.0, t)
	await tw.finished


func card(title: String, sub := "", hold := 2.4) -> void:
	dialogue.hide_box()
	card_title.text = title
	card_sub.text = sub
	var tw := create_tween().set_parallel(true)
	tw.tween_property(card_title, "modulate:a", 1.0, 1.0)
	tw.tween_property(card_sub, "modulate:a", 1.0, 1.4)
	await tw.finished
	await wait(hold)
	var tw2 := create_tween().set_parallel(true)
	tw2.tween_property(card_title, "modulate:a", 0.0, 0.8)
	tw2.tween_property(card_sub, "modulate:a", 0.0, 0.8)
	await tw2.finished


func chapter(num_title: String, sub: String) -> void:
	await fade_out(0.7)
	await card(num_title, sub, 1.8)
	await fade_in(0.7)


func goto_map(id: String, c: Vector2i, dir := 0, with_fade := true) -> void:
	if with_fade:
		AudioManager.sfx("door", 0.7)
		await fade_out(0.4)
	clear_actors()
	if map:
		map.queue_free()
	map = MapScene.new()
	map.setup(id)
	world.add_child(map)
	world.move_child(map, 1)
	if player == null:
		player = PlayerScript.new()
		entities.add_child(player)
		player.blocked_fn = is_blocked
		player.bumped.connect(_on_bump)
		player.stepped.connect(_on_step)
	player.visible = true
	player.map = map
	player.place(c, dir)
	canvas_mod.color = map.ambient
	rain.intensity = 1.0 if map.outdoor else 0.0
	AudioManager.set_rain(0.9 if map.outdoor else 0.35)
	hud_room.text = map.title
	_focus = null
	_update_camera()
	camera.reset_smoothing()
	story.on_map_loaded(id)
	if with_fade:
		await fade_in(0.4)


func is_blocked(c: Vector2i) -> bool:
	if map == null or map.is_blocked(c):
		return true
	for a in actors:
		if is_instance_valid(a) and a.visible and a.cell == c:
			return true
	return false


func unload_world() -> void:
	clear_actors()
	if map:
		map.queue_free()
		map = null
	if player:
		player.queue_free()
		player = null
	rain.intensity = 0.0


## kind: id de personaje ("ari", "damian", ...) o "ari_ghost".
func spawn(kind: String, c: Vector2i, dir := 0):
	var a = CharacterScript.new()
	a.setup("ari" if kind == "ari_ghost" else kind)
	if kind == "ari_ghost":
		a.set_ghost(true)
	a.place(c, dir)
	entities.add_child(a)
	actors.append(a)
	return a


func remove_actor(a) -> void:
	actors.erase(a)
	if is_instance_valid(a):
		a.queue_free()


func clear_actors() -> void:
	for a in actors:
		if is_instance_valid(a):
			a.queue_free()
	actors.clear()


func focus_cell(c: Vector2i) -> void:
	_focus = Vector2(c.x * 16 + 8, c.y * 16)


func follow() -> void:
	_focus = null


## "off", "happy" (sepia cálido), "dark" (rojo), "void" (casi negro)
func memory(mode: String, t := 1.0) -> void:
	var sepia := 0.0
	var red := 0.0
	var ab := 0.0
	var cm: Color = map.ambient if map else Color(0.3, 0.3, 0.4)
	match mode:
		"happy":
			sepia = 0.85
			cm = Color(0.95, 0.88, 0.78)
		"dark":
			red = 0.75
			ab = 0.003
			cm = Color(0.6, 0.48, 0.52)
		"void":
			red = 0.4
			ab = 0.005
			cm = Color(0.18, 0.14, 0.16)
	if mode != "off":
		AudioManager.sfx("static", 0.8)
	if map:
		map.lights_on = mode == "off" or mode == "happy"
	var tw := create_tween().set_parallel(true)
	tw.tween_method(_set_fx.bind("sepia"), fx_mat.get_shader_parameter("sepia"), sepia, t)
	tw.tween_method(_set_fx.bind("redness"), fx_mat.get_shader_parameter("redness"), red, t)
	tw.tween_method(_set_fx.bind("aberr"), fx_mat.get_shader_parameter("aberr"), ab, t)
	tw.tween_property(canvas_mod, "color", cm, t)
	await tw.finished


func _set_fx(v: float, param: String) -> void:
	fx_mat.set_shader_parameter(param, v)


func lightning() -> void:
	if map == null:
		return
	map.lightning()
	var base: Color = canvas_mod.color
	canvas_mod.color = Color(0.85, 0.88, 1.0)
	var tw := create_tween()
	tw.tween_property(canvas_mod, "color", base, 0.5)
	await wait(randf_range(0.4, 1.2))
	AudioManager.sfx("thunder", 0.9)


func shake(amount := 3.0, t := 0.4) -> void:
	var el := 0.0
	while el < t:
		camera.offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
		await get_tree().process_frame
		el += get_process_delta_time()
	camera.offset = Vector2.ZERO


func run_minigame(script: GDScript) -> Variant:
	dialogue.hide_box()
	hud_visible(false)
	var m: Control = script.new()
	minigame_holder.add_child(m)
	var r = await m.finished
	m.queue_free()
	hud_visible(map != null)
	return r
