extends Control
## Pantalla de teléfono para el prólogo: mensajes entre Ari y Edd.

signal _next

const PHONE := Rect2(440, 40, 400, 640)

var _list: VBoxContainer
var _typing: Label
var _header: Label
var _hint: Label
var _waiting := false
var _cool := 0.0
var _t := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_header = Label.new()
	_header.text = "Ari ♡"
	_header.position = PHONE.position + Vector2(0, 40)
	_header.size = Vector2(PHONE.size.x, 30)
	_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_header.add_theme_font_size_override("font_size", 22)
	add_child(_header)
	_list = VBoxContainer.new()
	_list.position = PHONE.position + Vector2(24, 90)
	_list.size = Vector2(PHONE.size.x - 48, PHONE.size.y - 185)
	_list.add_theme_constant_override("separation", 10)
	_list.alignment = BoxContainer.ALIGNMENT_END
	_list.clip_contents = true
	add_child(_list)
	_typing = Label.new()
	_typing.position = PHONE.position + Vector2(28, PHONE.size.y - 76)
	_typing.add_theme_font_size_override("font_size", 16)
	_typing.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	add_child(_typing)
	_hint = Label.new()
	_hint.text = "[E / clic] continuar"
	_hint.position = Vector2(PHONE.end.x + 20, PHONE.end.y - 30)
	_hint.add_theme_font_size_override("font_size", 14)
	_hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	add_child(_hint)


func _draw() -> void:
	draw_rect(PHONE.grow(14), Color(0.06, 0.06, 0.07))
	draw_rect(PHONE, Color(0.09, 0.1, 0.14))
	draw_rect(Rect2(PHONE.position, Vector2(PHONE.size.x, 80)), Color(0.12, 0.13, 0.18))
	draw_string(ThemeDB.fallback_font, PHONE.position + Vector2(16, 24), "02:47", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.8, 0.8, 0.85))
	draw_string(ThemeDB.fallback_font, PHONE.position + Vector2(PHONE.size.x - 70, 24), "▮▮▮ 12%", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.9, 0.4, 0.4))
	draw_rect(Rect2(PHONE.position.x, PHONE.end.y - 60, PHONE.size.x, 60), Color(0.12, 0.13, 0.18))
	draw_rect(Rect2(PHONE.position.x + 16, PHONE.end.y - 46, PHONE.size.x - 32, 32), Color(0.2, 0.2, 0.26))


func _process(delta: float) -> void:
	_t += delta
	_cool -= delta
	_hint.visible = _waiting
	_hint.modulate.a = 0.5 + 0.5 * sin(_t * 3.0)


func _input(event: InputEvent) -> void:
	if not _waiting or _cool > 0.0:
		return
	if event.is_action_pressed("interact") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		get_viewport().set_input_as_handled()
		_waiting = false
		_next.emit()


func wait_press() -> void:
	_waiting = true
	_cool = 0.25
	await _next


func message(from: String, text: String) -> void:
	if from == "Ari":
		_typing.text = "Ari está escribiendo..."
		await get_tree().create_timer(1.1).timeout
		_typing.text = ""
		AudioManager.sfx("buzz", 0.5)
	_add_bubble(from, text)
	await wait_press()


func system(text: String, col := Color(1.0, 0.35, 0.35)) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", col)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_list.add_child(l)
	_trim.call_deferred()


func _add_bubble(from: String, text: String) -> void:
	var row := HBoxContainer.new()
	var pc := PanelContainer.new()
	var st := StyleBoxFlat.new()
	st.set_corner_radius_all(12)
	st.set_content_margin_all(10)
	st.bg_color = Color(0.25, 0.25, 0.3) if from == "Ari" else Color(0.2, 0.4, 0.75)
	pc.add_theme_stylebox_override("panel", st)
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(minf(250, 12 + text.length() * 10.5), 0)
	l.add_theme_font_size_override("font_size", 17)
	pc.add_child(l)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if from == "Ari":
		row.add_child(pc)
		row.add_child(spacer)
	else:
		row.add_child(spacer)
		row.add_child(pc)
	_list.add_child(row)
	pc.modulate.a = 0.0
	create_tween().tween_property(pc, "modulate:a", 1.0, 0.25)
	_trim.call_deferred()


func _trim() -> void:
	var max_h := PHONE.size.y - 185.0
	while _list.get_child_count() > 1 and _list.get_combined_minimum_size().y > max_h:
		var c := _list.get_child(0)
		_list.remove_child(c)
		c.queue_free()
	_list.size = Vector2(PHONE.size.x - 48, PHONE.size.y - 185)
