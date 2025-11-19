@icon("res://icon.svg")
extends Resource
class_name SlotConfig

# The full symbol set used in the game
@export var symbols: Array[SlotSymbol] = []

# Number of reels the game should use
@export var reel_count: int = 3

# Payouts
@export var paytable: Paytable
