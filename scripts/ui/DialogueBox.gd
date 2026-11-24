extends Control
## Caja de diálogo estilo RPG de terror (Mad Father / Misao): retrato grande con emoción junto al texto.
## Uso: await dialogue.say("Ari:triste", "Texto")  -> personaje "Ari", emoción "triste".

signal advanced

const COLORS := {
	"Ari": Color(1.0, 0.62, 0.66),
	"Edd": Color(1.0, 0.82, 0.35),
	"Damián": Color(0.85, 0.6, 0.55),
	"Vera": Color(0.8, 0.6, 0.9),
	"Nico": Color(0.7, 0.8, 0.55),
	"Rivas": Color(0.85, 0.2, 0.25),
	"Claudia": Color(0.6, 0.8, 1.0),
}
## nombre en pantalla -> archivo de retrato
const PORTRAIT_ID := {
	"Ari": "ari", "Edd": "edd", "Damián": "damian", "Vera": "vera",
	"Nico": "nico", "Rivas": "rivas", "Claudia": "claudia",
}
const LEFT_SIDE := ["Edd"]
const SCALE := 3.0
const BOX := Rect2(20, 520, 1240, 190)

var box: Panel
var name_panel: PanelContainer
var name_label: Label
var text_label: Label
var arrow: Label
var portrait: TextureRect
var _style: StyleBoxFlat
var _name_style: StyleBoxFlat
var _typing := false
var _waiting := false
var _cooldown := 0.0
var _t := 0.0
var _char_acc := 0.0
var _last_speaker := ""
var _portrait_base := Vector2.ZERO
var cps := 40.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	box = Panel.new()
	box.position = BOX.position
	box.size = BOX.size
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style = StyleBoxFlat.new()
	_style.bg_color = Color(0.02, 0.02, 0.04, 0.9)
	_style.border_color = Color(0.75, 0.72, 0.8, 0.9)
	_style.set_border_width_all(3)
	_style.set_corner_radius_all(2)
	_style.shadow_color = Color(0, 0, 0, 0.6)
	_style.shadow_size = 6
	box.add_theme_stylebox_override("panel", _style)
	add_child(box)

	portrait = TextureRect.new()
	portrait.stretch_mode = TextureRect.STRETCH_SCALE
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)

	name_panel = PanelContainer.new()
	name_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_style = StyleBoxFlat.new()
	_name_style.bg_color = Color(0.05, 0.04, 0.07, 0.95)
	_name_style.border_color = Color(0.75, 0.72, 0.8, 0.9)
	_name_style.set_border_width_all(3)
	_name_style.content_margin_left = 16
	_name_style.content_margin_right = 16
	_name_style.content_margin_top = 4
	_name_style.content_margin_bottom = 4
	name_panel.add_theme_stylebox_override("panel", _name_style)
	add_child(name_panel)
	name_label = Label.new()
	name_label.add_theme_font_size_override("font_size", 24)
	name_panel.add_child(name_label)

	text_label = Label.new()
	text_label.add_theme_font_size_override("font_size", 26)
	text_label.add_theme_constant_override("line_spacing", 6)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	text_label.add_theme_constant_override("shadow_offset_x", 2)
	text_label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(text_label)

	arrow = Label.new()
	arrow.text = "▼"
	arrow.add_theme_font_size_override("font_size", 20)
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(arrow)


## speaker puede ser "Ari", "Ari:triste" o "" (narración).
func say(speaker: String, text: String, style := "") -> void:
	visible = true
	var emo := "neutral"
	if speaker.contains(":"):
		var parts := speaker.split(":")
		speaker = parts[0]
		emo = parts[1]
	_apply(speaker, emo, style)
	text_label.text = text
	text_label.visible_characters = 0
	_char_acc = 0.0
	_typing = true
	_waiting = true
	_cooldown = 0.15
	arrow.visible = false
	await advanced
	_waiting = false


func hide_box() -> void:
	visible = false
	_last_speaker = ""


func _portrait_tex(speaker: String, emo: String) -> Texture2D:
	if not PORTRAIT_ID.has(speaker):
		return null
	var pid: String = PORTRAIT_ID[speaker]
	var path := "res://assets/portraits/%s_%s.png" % [pid, emo]
	if not ResourceLoader.exists(path):
		path = "res://assets/portraits/%s_neutral.png" % pid
	return load(path)


func _apply(speaker: String, emo: String, style: String) -> void:
	var col: Color = COLORS.get(speaker, Color(0.85, 0.85, 0.9))
	_style.bg_color = Color(0.02, 0.02, 0.04, 0.9)
	_style.border_color = Color(0.75, 0.72, 0.8, 0.9)
	text_label.add_theme_color_override("font_color", Color(0.95, 0.94, 0.96))
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	box.visible = true
	var shown_name := speaker
	var tex: Texture2D = null
	if style != "void" and style != "recording":
		tex = _portrait_tex(speaker, emo)
	match style:
		"recording":
			shown_name = "▶ GRABACIÓN — " + speaker
			_style.bg_color = Color(0.01, 0.05, 0.03, 0.94)
			_style.border_color = Color(0.3, 0.9, 0.5, 0.8)
			text_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.78))
		"note":
			_style.bg_color = Color(0.86, 0.82, 0.72, 0.97)
			_style.border_color = Color(0.45, 0.32, 0.2)
			text_label.add_theme_color_override("font_color", Color(0.18, 0.1, 0.1))
			text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		"memory":
			_style.bg_color = Color(0.14, 0.09, 0.05, 0.9)
			_style.border_color = Color(0.95, 0.8, 0.55, 0.85)
		"dark":
			_style.bg_color = Color(0.09, 0.0, 0.01, 0.94)
			_style.border_color = Color(0.7, 0.06, 0.12, 0.9)
		"void":
			box.visible = false
			text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_style.border_color = _style.border_color
	name_label.text = shown_name
	name_label.add_theme_color_override("font_color", col)
	name_panel.visible = shown_name != "" and style != "void"
	if speaker == "" and style == "":
		text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text_label.add_theme_color_override("font_color", Color(0.78, 0.78, 0.84))

	# retrato grande
	var left := LEFT_SIDE.has(speaker)
	portrait.texture = tex
	portrait.visible = tex != null
	var text_x := BOX.position.x + 40
	var text_w := BOX.size.x - 80
	if tex:
		var sz := Vector2(tex.get_width(), tex.get_height()) * SCALE
		portrait.size = sz
		var px := 30.0 if left else 1250.0 - sz.x
		_portrait_base = Vector2(px, BOX.end.y - sz.y - 6)
		portrait.position = _portrait_base
		portrait.modulate = Color(1, 1, 1, 1)
		if style == "dark":
			portrait.modulate = Color(1.0, 0.75, 0.78)
		elif style == "memory":
			portrait.modulate = Color(1.0, 0.92, 0.8)
		if speaker != _last_speaker:
			portrait.position.x += -40.0 if left else 40.0
			portrait.modulate.a = 0.0
			var tw := create_tween().set_parallel(true)
			tw.tween_property(portrait, "position:x", _portrait_base.x, 0.18)
			tw.tween_property(portrait, "modulate:a", 1.0, 0.18)
		if left:
			text_x = px + sz.x + 10
		text_w = BOX.size.x - sz.x - 60
	_last_speaker = speaker
	if style == "void":
		text_label.position = Vector2(140, 300)
		text_label.size = Vector2(1000, 120)
	else:
		text_label.position = Vector2(text_x, BOX.position.y + 34)
		text_label.size = Vector2(text_w, BOX.size.y - 50)
	name_panel.position = Vector2(text_x - 6, BOX.position.y - 26)
	name_panel.reset_size()
	arrow.position = Vector2(text_x + text_w - 30, BOX.end.y - 34)


func _process(delta: float) -> void:
	_t += delta
	_cooldown -= delta
	if _typing:
		_char_acc += delta * cps
		var n := int(_char_acc)
		if n != text_label.visible_characters:
			text_label.visible_characters = n
			if n % 3 == 0:
				AudioManager.sfx("blip", 0.6)
		if n >= text_label.text.length():
			_typing = false
			text_label.visible_characters = -1
	arrow.visible = _waiting and not _typing
	arrow.modulate.a = 0.6 + 0.4 * sin(_t * 6.0)
	if portrait.visible and not _typing and _waiting:
		portrait.position.y = _portrait_base.y + sin(_t * 2.0) * 1.5


func _input(event: InputEvent) -> void:
	if not _waiting or _cooldown > 0.0:
		return
	var pressed: bool = event.is_action_pressed("interact") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	if not pressed:
		return
	get_viewport().set_input_as_handled()
	if _typing:
		_typing = false
		text_label.visible_characters = -1
		_cooldown = 0.1
	else:
		advanced.emit()
