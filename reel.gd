extends Control

# Symbols Reel can choose from
var symbols: Array[String] = ["A", "B", "C", "D", "E"]

# Reference to container holding the 3 rows
@onready var rows: VBoxContainer = $Frame/Rows

func _ready():
	# Optional: randomize once at startup
	set_random_symbols()

func set_random_symbols():
	# For each child in Rows (Row0, Row1, Row2)
	for child in rows.get_children():
		if child is Label:
			var s := symbols[randi() % symbols.size()]
			child.text = s

func get_center_symbol() -> String:
	# Row1 is the middle row
	if rows.get_child_count() >= 2:
		var child := rows.get_child(1)
		if child is Label:
			return child.text
	return ""
