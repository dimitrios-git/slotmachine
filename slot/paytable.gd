@icon("res://icon.svg")
extends Resource
class_name Paytable

# For each symbol:
#   key = SlotSymbol.id (String)
#   value = Dictionary of match_count → payout
# Example:
#   {
#     "A": {3: 50, 2: 5},
#     "B": {3: 30, 2: 5},
#     "C": {3: 20},
#     "D": {3: 10},
#     "E": {3: 5}
#   }
@export var payouts := {}
