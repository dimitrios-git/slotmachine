extends Node2D

var credits: int = 100
var spin_cost: int = 5

@onready var reel1 = $Reel1
@onready var reel2 = $Reel2
@onready var reel3 = $Reel3

@onready var spin_button: Button = $SpinButton
@onready var credits_label: Label = $CreditsLabel
@onready var result_label: Label = $ResultLabel

func _ready():
	update_ui()
	spin_button.pressed.connect(_on_spin_button_pressed)

func update_ui():
	credits_label.text = "Credits: %d" % credits

func _on_spin_button_pressed():
	if credits < spin_cost:
		result_label.text = "Not enough credits!"
		return

	# Pay for spin
	credits -= spin_cost
	update_ui()
	result_label.text = ""

	# Randomize all reels
	reel1.set_random_symbols()
	reel2.set_random_symbols()
	reel3.set_random_symbols()

	# Read the 3 center symbols
	var s1: String = reel1.get_center_symbol()
	var s2: String = reel2.get_center_symbol()
	var s3: String = reel3.get_center_symbol()

	evaluate_spin(s1, s2, s3)

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
