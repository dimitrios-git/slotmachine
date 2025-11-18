extends Control

signal spin_finished(symbol: String)

const SYMBOLS: Array[String] = ["A", "B", "C", "D", "E"]
const ROW_HEIGHT: float = 60.0
const SPIN_SPEED: float = 900.0   # px/sec
const SLOWDOWN_DISTANCE: float = 240.0   # when to start slowing down
const FINAL_STOP_OFFSET: float = 60.0    # how far we go after slowdown

@onready var container: Control = $Container
@onready var rows := [
	$Container/Row0,
	$Container/Row1,
	$Container/Row2
]

var spinning := false
var target_symbol: String = ""
var symbol_index := 0

func _ready():
	randomize()
	# assign random starting symbols
	for r in rows:
		r.text = SYMBOLS[randi() % SYMBOLS.size()]


func spin():
	if spinning:
		return

	spinning = true
	target_symbol = SYMBOLS[randi() % SYMBOLS.size()]

	# run the spinning in a coroutine
	_run_spin()


func _run_spin() -> void:
	var distance_spun := 0.0

	while distance_spun < SLOWDOWN_DISTANCE:
		var delta := get_process_delta_time()
		_move_rows(SPIN_SPEED * delta)
		distance_spun += SPIN_SPEED * delta
		await get_tree().process_frame

	# Slow down
	var slow_speed := SPIN_SPEED / 4.0
	var remaining := FINAL_STOP_OFFSET

	while remaining > 0:
		var delta := get_process_delta_time()
		var step := slow_speed * delta
		_move_rows(step)
		remaining -= step
		await get_tree().process_frame

	# snap nearest symbol into center
	_force_center_symbol(target_symbol)

	spinning = false
	emit_signal("spin_finished", target_symbol)


func _move_rows(distance: float) -> void:
	# move all rows downward
	for r in rows:
		r.position.y += distance

	# recycle rows going outside bottom
	for r in rows:
		if r.position.y >= ROW_HEIGHT * 3:
			r.position.y -= ROW_HEIGHT * 3
			# Assign new random symbol
			symbol_index = (symbol_index + 1) % SYMBOLS.size()
			r.text = SYMBOLS[symbol_index]


func _force_center_symbol(symbol: String) -> void:
	# Assign exactly 3 rows:
	# above, center, below
	var idx := SYMBOLS.find(symbol)
	var above := SYMBOLS[(idx - 1 + SYMBOLS.size()) % SYMBOLS.size()]
	var below := SYMBOLS[(idx + 1) % SYMBOLS.size()]

	rows[0].text = above
	rows[1].text = symbol   # center row
	rows[2].text = below

	# Set perfect row positions
	rows[0].position.y = 0
	rows[1].position.y = ROW_HEIGHT
	rows[2].position.y = ROW_HEIGHT * 2
