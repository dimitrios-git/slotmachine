extends Node
class_name SlotManager

@export var config: SlotConfig
@export var reels: Array[Node]

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
	if symbols.is_empty():
		return 0

	# Count how many times each symbol ID appears
	var counts: Dictionary = {}

	for s: SlotSymbol in symbols:
		var id: String = s.id
		var existing: int = counts.get(id, 0)
		counts[id] = existing + 1

	var best_symbol: String = ""
	var best_count: int = 0

	for symbol_id: String in counts.keys():
		var count: int = counts[symbol_id]
		if count > best_count:
			best_count = count
			best_symbol = symbol_id

	# Look up payouts from paytable
	var symbol_table: Dictionary = config.paytable.payouts.get(best_symbol, {})
	var payout: int = symbol_table.get(best_count, 0)

	return payout
