extends Control
## Inventario: los 8 objetos de Ari + objetos extra. Se abre con TAB o I.

const ItemIcon := preload("res://scripts/ui/ItemIcon.gd")

var _icons: Array = []
var _title: Label
var _desc: Label
var _stats: Label
var _sel := 0
var _order: Array = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.82)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var head := Label.new()
	head.text = "LO QUE QUEDA DE ARI"
	head.position = Vector2(0, 60)
	head.size = Vector2(1280, 40)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_theme_font_size_override("font_size", 30)
	head.add_theme_color_override("font_color", Color(0.95, 0.7, 0.72))
	add_child(head)
	_order = GameState.EVIDENCE + ["linterna", "carpeta"]
	for i in _order.size():
		var ic := ItemIcon.new()
		var col := i % 5
		var row := i / 5
		ic.position = Vector2(290 + col * 145, 140 + row * 145)
		ic.size = Vector2(120, 120)
		ic.mouse_entered.connect(_select.bind(i))
		add_child(ic)
		_icons.append(ic)
	_title = Label.new()
	_title.position = Vector2(240, 450)
	_title.size = Vector2(800, 36)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 26)
	_title.add_theme_color_override("font_color", Color(1, 0.85, 0.5))
	add_child(_title)
	_desc = Label.new()
	_desc.position = Vector2(240, 495)
	_desc.size = Vector2(800, 90)
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_desc.add_theme_font_size_override("font_size", 20)
	add_child(_desc)
	_stats = Label.new()
	_stats.position = Vector2(0, 610)
	_stats.size = Vector2(1280, 30)
	_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stats.add_theme_font_size_override("font_size", 18)
	_stats.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	add_child(_stats)
	var hint := Label.new()
	hint.text = "[TAB / I] cerrar    [← →] mover"
	hint.position = Vector2(0, 660)
	hint.size = Vector2(1280, 30)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 15)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	add_child(hint)


func open() -> void:
	for i in _order.size():
		_icons[i].set_item(_order[i], GameState.has_item(_order[i]))
		_icons[i].visible = i < GameState.EVIDENCE.size() or GameState.has_item(_order[i])
	_stats.text = "Recuerdos: %d / 8      Pistas ocultas: %d / 4" % [GameState.evidence_count(), GameState.clues.size()]
	_select(0)
	visible = true


func close() -> void:
	visible = false


func _select(i: int) -> void:
	_sel = i
	for k in _icons.size():
		_icons[k].selected = k == i
		_icons[k].queue_redraw()
	var id: String = _order[i]
	if GameState.has_item(id):
		_title.text = GameState.ITEMS[id].name
		_desc.text = GameState.ITEMS[id].desc
	else:
		_title.text = "???"
		_desc.text = "Todavía no lo encuentro."


func _input(event: InputEvent) -> void:
	if not visible:
		return
	var n := 0
	for k in _icons.size():
		if _icons[k].visible:
			n = k + 1
	if event.is_action_pressed("move_right"):
		_select((_sel + 1) % n)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_left"):
		_select((_sel - 1 + n) % n)
		get_viewport().set_input_as_handled()
