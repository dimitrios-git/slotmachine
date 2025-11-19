extends Node
class_name SlotManager

@export var config: SlotConfig
@export var reels: Array[Node]

signal spin_complete(result_symbols: Array[SlotSymbol], payout: int)


func _ready():
	call_deferred("initialize_reels")

func initialize_reels():
	print("=== INITIALIZE REELS ===")
	print("Config symbols count: ", config.symbols.size())
	print("Reels in manager: ", reels)

	if config == null:
		push_error("SlotManager: config not assigned!")
		return

	for reel in reels:
		print("Assigning symbols to: ", reel.name)

		if "set_symbol_list" in reel:
			reel.set_symbol_list(config.symbols)
			print("  -> assigned ", config.symbols.size(), " symbols")
			reel.initialize_reel()
		else:
			push_error("%s is not a reel with set_symbol_list()" % reel.name)



func spin() -> Array[SlotSymbol]:
	var results: Array[SlotSymbol] = []

	for i in range(config.reel_count):
		results.append(weighted_random_symbol())

	for i in range(reels.size()):
		reels[i].spin(results[i])

	return results


func weighted_random_symbol() -> SlotSymbol:
	var total := 0
	for s in config.symbols:
		total += s.weight

	var pick := randi() % total

	for s in config.symbols:
		pick -= s.weight
		if pick < 0:
			return s

	return config.symbols[0]


func evaluate(symbols: Array[SlotSymbol]) -> int:
	var counts := {}

	for s in symbols:
		counts[s.id] = (counts.get(s.id, 0) + 1)

	var highest := 0
	for k in counts.keys():
		highest = max(highest, counts[k])

	return config.payouts.get(highest, 0)
