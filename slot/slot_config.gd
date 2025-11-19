@icon("res://icon.svg")
extends Resource
class_name SlotConfig

# The full symbol set used in the game
@export var symbols: Array[SlotSymbol] = []

# Number of reels the game should use
@export var reel_count: int = 3

# Payouts: match_count -> credit reward
# (phase 2 simple version)
@export var payouts := {
	3: 50, # three of a kind
	2: 10  # two of a kind
}
