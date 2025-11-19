@icon("res://icon.svg")
extends Resource
class_name SlotSymbol

# Internal ID / label
@export var id: String = ""

# Odds weight (higher = more common)
@export var weight: int = 1

# Future-proof fields
@export var is_wild: bool = false
@export var is_scatter: bool = false

# Future reference for sprites (not used yet)
@export var icon: Texture2D
