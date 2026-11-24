extends Control
## Menú de opciones. Uso: var i = await choice.ask("¿Pregunta?", ["A", "B"])

signal chosen(index: int)

var _box: VBoxContainer
var _panel: PanelContainer
var _prompt: Label
var _buttons: Array = []
var _sel := 0
var _active := false
var _cool := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var panel := PanelContainer.new()
	_panel = panel
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.03, 0.03, 0.05, 0.95)
	st.border_color = Color(0.7, 0.7, 0.8, 0.6)
	st.set_border_width_all(2)
	st.set_corner_radius_all(6)
	st.set_content_margin_all(22)
	panel.add_theme_stylebox_override("panel", st)
	panel.position = Vector2(340, 220)
	panel.custom_minimum_size = Vector2(600, 0)
	add_child(panel)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 10)
	panel.add_child(_box)
	_prompt = Label.new()
	_prompt.add_theme_font_size_override("font_size", 24)
	_prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_prompt.custom_minimum_size = Vector2(556, 0)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(_prompt)


func ask(prompt: String, options: Array) -> int:
	for b in _buttons:
		_box.remove_child(b)
		b.queue_free()
	_buttons.clear()
	_prompt.text = prompt
	_prompt.visible = prompt != ""
	for i in options.size():
		var b := Button.new()
		b.text = options[i]
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 22)
		b.custom_minimum_size = Vector2(556, 44)
		b.pressed.connect(_pick.bind(i))
		b.mouse_entered.connect(_hover.bind(i))
		_box.add_child(b)
		_buttons.append(b)
	_sel = 0
	_refresh()
	_panel.reset_size()
	_panel.position = Vector2(640 - 322, 260 - options.size() * 20)
	visible = true
	_active = true
	_cool = 0.2
	var r: int = await chosen
	return r


func _pick(i: int) -> void:
	if not _active or _cool > 0.0:
		return
	_active = false
	visible = false
	AudioManager.sfx("blip", 1.0)
	chosen.emit(i)


func _hover(i: int) -> void:
	_sel = i
	_refresh()


func _refresh() -> void:
	for i in _buttons.size():
		var b: Button = _buttons[i]
		b.modulate = Color(1, 0.9, 0.6) if i == _sel else Color(0.8, 0.8, 0.85)


func _process(delta: float) -> void:
	_cool -= delta


func _input(event: InputEvent) -> void:
	if not _active:
		return
	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		_sel = (_sel - 1 + _buttons.size()) % _buttons.size()
		_refresh()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down") or (event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_S):
		_sel = (_sel + 1) % _buttons.size()
		_refresh()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_pick(_sel)
