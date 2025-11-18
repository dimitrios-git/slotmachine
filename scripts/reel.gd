extends Node2D

var symbols = ["A", "B", "C", "D", "E"]
var current_symbol = "A"
var spinning = false

@onready var label = $SymbolLabel
@onready var anim = $AnimationPlayer

func _ready():
	label.text = current_symbol

func spin():
	spinning = true
	anim.play("spin")

func stop():
	spinning = false
	anim.stop() # stop spin animation
	current_symbol = symbols.pick_random()
	label.text = current_symbol
	
	# effects
	anim.play("glow")
	anim.play("bounce")

	return current_symbol
