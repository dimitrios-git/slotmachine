extends Node2D

var credits: int = 100
var spin_cost: int = 5

@onready var reels: Array = get_tree().get_nodes_in_group("slot_reel")

@onready var spin_button: Button = $SpinButton
@onready var credits_label: Label = $CreditsLabel
@onready var result_label: Label = $ResultLabel

var results: Array[String] = []


func _ready():
	print("======================")
	print("DEBUG START")
	print("Reels found:", reels)
	for r in reels:
		print(" - Reel:", r.name)
	print("======================")

	update_ui()
	spin_button.pressed.connect(_on_spin_pressed)

	for reel in reels:
		reel.spin_finished.connect(_on_reel_finished)


func update_ui():
	credits_label.text = "Credits: %d" % credits


func _on_spin_pressed():
	print("SPIN PRESSED")
	print("Credits:", credits, "Cost:", spin_cost)

	if credits < spin_cost:
		print("Not enough credits")
		result_label.text = "Not enough credits!"
		return

	credits -= spin_cost
	update_ui()
	result_label.text = ""
	spin_button.disabled = true
	results.clear()

	print("Spinning reels:", reels)

	for reel in reels:
		var symbol := random_symbol_for(reel)
		print("Calling spin() on:", reel.name, "target =", symbol)
		reel.spin(symbol)


func random_symbol_for(reel) -> String:
	return reel.symbols[randi() % reel.symbols.size()]


func _on_reel_finished(symbol: String):
	print("Reel finished with:", symbol)
	results.append(symbol)

	if results.size() == reels.size():
		print("All reels finished:", results)
		evaluate_spin(results)
		spin_button.disabled = false


func evaluate_spin(symbols: Array[String]):
	print("Evaluating:", symbols)

	var counts := {}

	for s in symbols:
		counts[s] = (counts.get(s, 0) + 1)

	var highest := 0
	for k in counts.keys():
		highest = max(highest, counts[k])

	if highest >= 3:
		credits += 50
		result_label.text = "JACKPOT! +50"
	elif highest == 2:
		credits += 10
		result_label.text = "Nice! +10"
	else:
		result_label.text = "No win."

	update_ui()
