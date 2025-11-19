extends Control

signal spin_finished(symbol: String)

@export var symbols: Array[String] = ["A", "B", "C", "D", "E"]

@export var spin_speed: float = 900.0
@export var slowdown_distance: float = 240.0
@export var final_stop_offset: float = 60.0

@onready var container: Control = $Container
@onready var rows: Array[Control] = []

var row_height: float
var spinning: bool = false
var target_symbol: String = ""
var symbol_index: int = 0


func _ready():
	randomize()

	# Dynamically find all row nodes (strictly Control only)
	rows.clear()
	for child in container.get_children():
		if child is Control:
			rows.append(child)

	if rows.is_empty():
		push_error("Reel has no valid row nodes!")
		return

	row_height = rows[0].size.y

	# Initialize with random symbols
	for r in rows:
		r.text = symbols[randi() % symbols.size()]


func spin(symbol: String):
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

	# Wrap any row exiting the bottom
	for r in rows:
		if r.position.y >= total_height:
			r.position.y -= total_height
			symbol_index = (symbol_index + 1) % symbols.size()
			r.text = symbols[symbol_index]


func _set_center_symbol(symbol: String) -> void:
	var idx := symbols.find(symbol)
	if idx == -1:
		idx = 0

	var center := rows.size() / 2

	# Align each row to proper symbol
	for i in range(rows.size()):
		var sym_idx := (idx + (i - center) + symbols.size()) % symbols.size()
		rows[i].text = symbols[sym_idx]
		rows[i].position.y = row_height * i
