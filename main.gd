extends Node2D

@export var slot_manager: SlotManager

var credits: int = 100
var spin_cost: int = 5

@onready var spin_button: Button = $SpinButton
@onready var credits_label: Label = $CreditsLabel
@onready var result_label: Label = $ResultLabel

var finished_reels := 0
var current_results: Array[SlotSymbol] = []


func _ready():
	if slot_manager == null:
		push_error("Main: slot_manager is not assigned!")
		return

	update_ui()

	# Connect reel finish signals
	for reel in slot_manager.reels:
		reel.spin_finished.connect(_on_reel_finished)

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

	# Reset state
	finished_reels = 0

	# Manager decides the target symbols (returns Array[SlotSymbol])
	current_results = slot_manager.spin()

	spin_button.disabled = true


func _on_reel_finished(symbol: SlotSymbol):
	finished_reels += 1

	# All reels finished?
	if finished_reels == slot_manager.config.reel_count:
		var payout: int = slot_manager.evaluate(current_results)

		if payout > 0:
			result_label.text = "WIN! +%d" % payout
			credits += payout
		else:
			result_label.text = "No win"

		update_ui()
		spin_button.disabled = false
