extends Node
## Audio procedural (sin archivos): lluvia, caja de música, vibración del teléfono, truenos y efectos.
## Puedes reemplazarlo por archivos .ogg más adelante usando AudioStreamPlayer normales.

const RATE := 22050.0

var _player: AudioStreamPlayer
var _pb: AudioStreamGeneratorPlayback

# Lluvia
var rain_target := 0.0
var _rain_vol := 0.0
var _lp1 := 0.0
var _lp2 := 0.0

# Caja de música (la canción de Ari)
const MELODY := [
	[76, 1.0], [74, 0.5], [72, 0.5], [71, 1.0], [72, 0.5], [74, 0.5],
	[76, 1.0], [79, 1.0], [77, 2.0],
	[76, 1.0], [74, 0.5], [72, 0.5], [71, 1.0], [69, 0.5], [71, 0.5],
	[72, 1.0], [71, 1.0], [69, 2.0],
]
var melody_target := 0.0
var melody_detune := 1.0
var _mel_vol := 0.0
var _mel_on := false
var _mel_idx := 0
var _mel_time := 0.0
var _mel_freq := 440.0
var _mel_phase := 0.0
var _mel_env := 0.0
const BEAT := 0.42

# Drone de tensión
var drone_target := 0.0
var _drone_vol := 0.0
var _drone_phase := 0.0
var _drone_phase2 := 0.0

class Voice:
	var kind := ""
	var t := 0.0
	var dur := 0.0
	var freq := 0.0
	var phase := 0.0
	var lp := 0.0
	var vol := 1.0

var _voices: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = RATE
	gen.buffer_length = 0.25
	_player = AudioStreamPlayer.new()
	_player.stream = gen
	_player.volume_db = -4.0
	add_child(_player)
	_player.play()
	_pb = _player.get_stream_playback()


func set_rain(v: float) -> void:
	rain_target = v


func play_melody(volume := 0.5, detune := 1.0) -> void:
	if not _mel_on:
		_mel_idx = 0
		_mel_time = 0.0
		_start_note()
	_mel_on = true
	melody_target = volume
	melody_detune = detune


func stop_melody() -> void:
	melody_target = 0.0


func set_drone(v: float) -> void:
	drone_target = v


func sfx(kind: String, vol := 1.0) -> void:
	var v := Voice.new()
	v.kind = kind
	v.vol = vol
	match kind:
		"blip":
			v.dur = 0.035
			v.freq = randf_range(520.0, 600.0)
		"buzz":
			v.dur = 1.1
			v.freq = 140.0
		"thunder":
			v.dur = 3.0
		"heartbeat":
			v.dur = 0.9
			v.freq = 52.0
		"static":
			v.dur = 0.6
		"pickup":
			v.dur = 0.9
			v.freq = 880.0
		"door":
			v.dur = 0.5
			v.freq = 90.0
		"step":
			v.dur = 0.06
		"wrong":
			v.dur = 0.35
			v.freq = 110.0
		_:
			v.dur = 0.2
			v.freq = 440.0
	_voices.append(v)


func _midi(n: int) -> float:
	return 440.0 * pow(2.0, (n - 69) / 12.0)


func _start_note() -> void:
	_mel_freq = _midi(MELODY[_mel_idx][0])
	_mel_env = 1.0


func _process(_delta: float) -> void:
	if _pb == null:
		return
	var frames := _pb.get_frames_available()
	var dt := 1.0 / RATE
	for i in frames:
		# volúmenes suavizados
		_rain_vol += (rain_target - _rain_vol) * 0.0004
		_mel_vol += (melody_target - _mel_vol) * 0.0003
		_drone_vol += (drone_target - _drone_vol) * 0.0002
		var s := 0.0
		# lluvia: ruido blanco filtrado
		if _rain_vol > 0.001:
			var n := randf() * 2.0 - 1.0
			_lp1 += (n - _lp1) * 0.35
			_lp2 += (n - _lp2) * 0.04
			s += (_lp1 * 0.22 + _lp2 * 0.5) * _rain_vol
		# caja de música
		if _mel_on and _mel_vol > 0.001:
			_mel_time += dt
			var dur: float = MELODY[_mel_idx][1] * BEAT
			if _mel_time >= dur:
				_mel_time -= dur
				_mel_idx = (_mel_idx + 1) % MELODY.size()
				_start_note()
			_mel_env *= 0.99985
			_mel_phase += _mel_freq * melody_detune * dt
			var p := TAU * _mel_phase
			s += (sin(p) + 0.35 * sin(2.0 * p) + 0.12 * sin(3.0 * p)) * _mel_env * _mel_vol * 0.18
		elif _mel_on and melody_target <= 0.0 and _mel_vol <= 0.001:
			_mel_on = false
		# drone
		if _drone_vol > 0.001:
			_drone_phase += 55.0 * dt
			_drone_phase2 += 55.7 * dt
			s += (sin(TAU * _drone_phase) + sin(TAU * _drone_phase2)) * 0.12 * _drone_vol
		# efectos
		if not _voices.is_empty():
			s += _mix_voices(dt)
		s = clampf(s, -1.0, 1.0)
		_pb.push_frame(Vector2(s, s))


func _mix_voices(dt: float) -> float:
	var out := 0.0
	var i := _voices.size() - 1
	while i >= 0:
		var v: Voice = _voices[i]
		v.t += dt
		if v.t >= v.dur:
			_voices.remove_at(i)
			i -= 1
			continue
		var k := v.t / v.dur
		var x := 0.0
		match v.kind:
			"blip":
				v.phase += v.freq * dt
				x = sin(TAU * v.phase) * (1.0 - k) * 0.08
			"buzz":
				v.phase += v.freq * dt
				var gate := 1.0 if fmod(v.t, 0.5) < 0.32 else 0.0
				x = (1.0 if fmod(v.phase, 1.0) < 0.5 else -1.0) * gate * 0.12
			"thunder":
				var n := randf() * 2.0 - 1.0
				v.lp += (n - v.lp) * 0.02
				x = v.lp * 2.5 * pow(1.0 - k, 2.0) * min(1.0, v.t * 8.0)
			"heartbeat":
				v.phase += v.freq * dt
				var e := exp(-v.t * 18.0) + exp(-maxf(0.0, v.t - 0.28) * 18.0) * (1.0 if v.t > 0.28 else 0.0)
				x = sin(TAU * v.phase) * e * 0.6
			"static":
				x = (randf() * 2.0 - 1.0) * (1.0 - k) * 0.25
			"pickup":
				var f := v.freq if v.t < 0.25 else v.freq * 1.5
				v.phase += f * dt
				x = sin(TAU * v.phase) * (1.0 - k) * 0.15
			"door":
				var n2 := randf() * 2.0 - 1.0
				v.lp += (n2 - v.lp) * 0.05
				v.phase += (v.freq - 40.0 * k) * dt
				x = (v.lp * 0.5 + sin(TAU * v.phase) * 0.3) * (1.0 - k)
			"step":
				var n3 := randf() * 2.0 - 1.0
				v.lp += (n3 - v.lp) * 0.15
				x = v.lp * (1.0 - k) * 0.35
			"wrong":
				v.phase += (v.freq - 30.0 * k) * dt
				x = (1.0 if fmod(v.phase, 1.0) < 0.5 else -1.0) * (1.0 - k) * 0.08
			_:
				v.phase += v.freq * dt
				x = sin(TAU * v.phase) * (1.0 - k) * 0.1
		out += x * v.vol
		i -= 1
	return out
