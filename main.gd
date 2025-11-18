extends Node2D

var credits: int = 100
var spin_cost: int = 5

@onready var reel1 = $Reel1
@onready var reel2 = $Reel2
@onready var reel3 = $Reel3

@onready var spin_button: Button = $SpinButton
@onready var credits_label: Label = $CreditsLabel
@onready var result_label: Label = $ResultLabel

var results: Array[String] = []

func _ready():
	update_ui()

	# Connect button
	spin_button.pressed.connect(_on_spin_button_pressed)

	# Connect reel finished signals
	reel1.spin_finished.connect(_on_reel_finished)
	reel2.spin_finished.connect(_on_reel_finished)
	reel3.spin_finished.connect(_on_reel_finished)

func update_ui():
	credits_label.text = "Credits: %d" % credits

func _on_spin_button_pressed():
	if credits < spin_cost:
		result_label.text = "Not enough credits!"
		return

	# Deduct cost
	credits -= spin_cost
	update_ui()
	result_label.text = ""

	# Disable button during spin
	spin_button.disabled = true

	# Prepare for new results
	results.clear()

	# Start all reels simultaneously
	reel1.spin()
	reel2.spin()
	reel3.spin()

func _on_reel_finished(symbol: String):
	results.append(symbol)

	# When all 3 reels finished
	if results.size() == 3:
		evaluate_spin(results[0], results[1], results[2])
		spin_button.disabled = false

func evaluate_spin(s1: String, s2: String, s3: String):
	if s1 == s2 and s2 == s3:
		credits += 50
		result_label.text = "JACKPOT! +50"
	elif s1 == s2 or s2 == s3 or s1 == s3:
		credits += 10
		result_label.text = "Nice! +10"
	else:
		result_label.text = "No win."

	update_ui()
