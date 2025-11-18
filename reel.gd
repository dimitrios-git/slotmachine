extends Control

signal spin_finished(final_symbol: String)

var symbols: Array[String] = ["A", "B", "C", "D", "E"]
var spinning := false

@onready var rows: VBoxContainer = $Frame/Rows

func _ready():
	set_random_symbols()

func set_random_symbols():
	for child in rows.get_children():
		if child is Label:
			child.text = symbols[randi() % symbols.size()]

func get_center_symbol() -> String:
	var child := rows.get_child(1)
	return child.text if child is Label else ""

func spin():
	if spinning:
		return

	spinning = true

	var flicker_count := 8
	var flicker_delay := 0.03  # fast flicker

	_do_flicker(flicker_count, flicker_delay)

func _do_flicker(count: int, delay: float):
	if count <= 0:
		# Done flickering, pick final result
		set_random_symbols()
		spinning = false
		emit_signal("spin_finished", get_center_symbol())
		return

	set_random_symbols()

	var timer := get_tree().create_timer(delay)
	timer.timeout.connect(func():
		_do_flicker(count - 1, delay))
