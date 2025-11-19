extends Control

signal spin_finished(symbol: SlotSymbol)

var symbols: Array[SlotSymbol] = []

@export var spin_speed: float = 900.0
@export var slowdown_distance: float = 240.0
@export var final_stop_offset: float = 60.0

@onready var container: Control = $Container
@onready var rows: Array[Control] = []

var row_height: float
var spinning: bool = false
var target_symbol: SlotSymbol
var symbol_index: int = 0

func set_symbol_list(list: Array[SlotSymbol]) -> void:
	symbols = list

func _ready():
	randomize()

	# Collect rows dynamically
	rows.clear()
	for child in container.get_children():
		if child is Control:
			rows.append(child)

	if rows.is_empty():
		push_error("Reel has no valid row nodes!")
		return

	row_height = rows[0].size.y

	# Initialize rows with random symbol IDs
	# Initial symbols will be assigned later by SlotManager

func initialize_reel():
	if symbols.is_empty():
		push_error("%s: symbols not assigned before initialize_reel()" % name)
		return

	# Initialize rows with random IDs
	for r in rows:
		var s: SlotSymbol = symbols[randi() % symbols.size()]
		r.text = s.id

func spin(symbol: SlotSymbol):
	if spinning:
		return

	spinning = true
	target_symbol = symbol
	_run_spin()


func _run_spin() -> void:
	var moved := 0.0

	# --- Fast phase ---
	while moved < slowdown_distance:
		var delta := get_process_delta_time()
		var step := spin_speed * delta
		_move_rows(step)
		moved += step
		await get_tree().process_frame

	# --- Slow final approach ---
	var slow_speed := spin_speed * 0.25
	var remaining := final_stop_offset

	while remaining > 0:
		var delta := get_process_delta_time()
		var step := slow_speed * delta
		_move_rows(step)
		remaining -= step
		await get_tree().process_frame

	# --- Hard align to target ---
	_set_center_symbol(target_symbol)

	spinning = false
	emit_signal("spin_finished", target_symbol)


func _move_rows(distance: float) -> void:
	var total_height := row_height * rows.size()

	# Move rows down
	for r in rows:
		r.position.y += distance

	# Wrap rows
	for r in rows:
		if r.position.y >= total_height:
			r.position.y -= total_height
			symbol_index = (symbol_index + 1) % symbols.size()
			var s: SlotSymbol = symbols[symbol_index]
			r.text = s.id


func _set_center_symbol(symbol: SlotSymbol) -> void:
	# Find index of target in symbols array
	var idx := symbols.find(symbol)
	if idx == -1:
		idx = 0

	var center := rows.size() / 2

	# Align rows around the target symbol
	for i in range(rows.size()):
		var sym_idx := (idx + (i - center) + symbols.size()) % symbols.size()
		var s: SlotSymbol = symbols[sym_idx]
		rows[i].text = s.id
		rows[i].position.y = row_height * i
