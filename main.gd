extends Node2D

@export var slot_manager: SlotManager
var credits := 100
var spin_cost := 5

@onready var spin_button: Button = $SpinButton
@onready var credits_label: Label = $CreditsLabel
@onready var result_label: Label = $ResultLabel

var finished_count := 0
var current_results: Array[String] = []

func _ready():
	update_ui()

	# Hook reel finish signals
	for r in slot_manager.reels:
		r.spin_finished.connect(_on_reel_finished)

	spin_button.pressed.connect(_on_spin_pressed)

func update_ui():
	credits_label.text = "Credits: %d" % credits

func _on_spin_pressed():
	if credits < spin_cost:
		result_label.text = "Not enough credits!"
		return

	credits -= spin_cost
	update_ui()
	result_label.text = ""

	finished_count = 0
	current_results = slot_manager.spin()

	spin_button.disabled = true

func _on_reel_finished(symbol: String):
	finished_count += 1

	if finished_count == slot_manager.config.reel_count:
		var payout := slot_manager.evaluate(current_results)
		credits += payout

		if payout > 0:
			result_label.text = "WIN! +%d" % payout
		else:
			result_label.text = "No win"

		update_ui()
		spin_button.disabled = false
