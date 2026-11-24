extends Node
## Estado global de la partida: objetos, pistas ocultas y banderas de historia.

signal inventory_changed

const EVIDENCE := ["liston", "peluche", "fotografia", "reproductor", "broche", "candado", "cuchillo", "diario"]
const CLUES := ["nota_peluche", "lupa_foto", "fechas_cuchillo", "uv_diario"]

const ITEMS := {
	"liston": {"name": "El listón", "desc": "Su accesorio favorito. Se lo regalé un 14 de marzo, el aniversario del día en que nos conocimos."},
	"peluche": {"name": "El peluche", "desc": "Uno de mis regalos. \"Tú solo tienes que cuidarlo.\""},
	"fotografia": {"name": "La fotografía", "desc": "Ari y yo sonriendo. Yo creía que era un día feliz."},
	"reproductor": {"name": "El reproductor", "desc": "Su viejo reproductor. Todas las canciones que compartíamos... y algo más."},
	"broche": {"name": "El broche", "desc": "El imperdible con el que arreglé su abrigo. \"Me atoré con una puerta.\""},
	"candado": {"name": "El candado", "desc": "Nuestro escondite secreto. Dentro estaba su denuncia."},
	"cuchillo": {"name": "El cuchillo", "desc": "Etiqueta de mantenimiento. Nunca fue de Ari."},
	"diario": {"name": "El diario", "desc": "Dibujos de edificios, canciones, fechas. \"No todo se puede ver.\""},
	"linterna": {"name": "Linterna UV", "desc": "Ari la usaba para escribir mensajes que solo se veían con luz ultravioleta."},
	"carpeta": {"name": "Carpeta de Claudia", "desc": "\"Solo quiero que esta vez alguien la escuche.\" — C. Montes"},
}

var items: Array[String] = []
var clues: Array[String] = []
var flags := {}


func _ready() -> void:
	_setup_input()


func reset() -> void:
	items.clear()
	clues.clear()
	flags.clear()
	inventory_changed.emit()


func add_item(id: String) -> void:
	if not items.has(id):
		items.append(id)
		inventory_changed.emit()


func has_item(id: String) -> bool:
	return items.has(id)


func add_clue(id: String) -> void:
	if not clues.has(id):
		clues.append(id)
		inventory_changed.emit()


func has_clue(id: String) -> bool:
	return clues.has(id)


func flag(id: String) -> bool:
	return flags.get(id, false)


func set_flag(id: String, v := true) -> void:
	flags[id] = v


func evidence_count() -> int:
	var n := 0
	for e in EVIDENCE:
		if items.has(e):
			n += 1
	return n


## Puntuación para decidir el final: 8 objetos + 4 pistas ocultas = 12.
func score() -> int:
	return evidence_count() + clues.size()


func ending() -> String:
	if evidence_count() == EVIDENCE.size() and clues.size() == CLUES.size():
		return "verdadero"
	if score() >= 8:
		return "incompleto"
	return "oscuro"


func _setup_input() -> void:
	var map := {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"interact": [KEY_E, KEY_Z, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER],
		"inventory": [KEY_TAB, KEY_I, KEY_X],
		"pause": [KEY_ESCAPE],
	}
	for action in map:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in map[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)
