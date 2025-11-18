extends Node2D

var credits = 100
var spin_cost = 5

@onready var reel1 = $Reel1
@onready var reel2 = $Reel2
@onready var reel3 = $Reel3

@onready var spin_button = $SpinButton
@onready var credits_label = $CreditsLabel
@onready var result_label = $ResultLabel

func _ready():
	update_ui()

func update_ui():
	credits_label.text = "Credits: %s" % credits

func _on_spin_button_pressed():
	if credits < spin_cost:
		result_label.text = "Not enough credits!"
		return

	credits -= spin_cost
	update_ui()
	result_label.text = ""

	# Start reels one by one
	reel1.spin()
	await get_tree().create_timer(0.2).timeout
	reel2.spin()
	await get_tree().create_timer(0.2).timeout
	reel3.spin()

	# Stop reels one by one
	await get_tree().create_timer(1.0).timeout
	var s1 = reel1.stop()
	await get_tree().create_timer(0.5).timeout
	var s2 = reel2.stop()
	await get_tree().create_timer(0.5).timeout
	var s3 = reel3.stop()

	evaluate_spin(s1, s2, s3)

func evaluate_spin(s1, s2, s3):
	if s1 == s2 and s2 == s3:
		credits += 50
		result_label.text = "JACKPOT! +50"
	elif s1 == s2 or s2 == s3 or s1 == s3:
		credits += 10
		result_label.text = "Nice! +10"
	else:
		result_label.text = "No win."

	update_ui()
