extends Node
class_name SlotManager

@export var config: SlotConfig
@export var reels: Array[Node]

signal spin_complete(result_symbols: Array[String], payout: int)

func spin():
	var results: Array[String] = []

	# Pick target symbols
	for i in range(config.reel_count):
		var s = config.symbols[randi() % config.symbols.size()]
		results.append(s)

	# Send target symbols to reels
	for i in range(reels.size()):
		reels[i].spin(results[i])

	return results

func evaluate(symbols: Array[String]) -> int:
	var counts := {}
	for s in symbols:
		counts[s] = (counts.get(s, 0) + 1)

	var highest := 0
	for k in counts:
		highest = max(highest, counts[k])

	return config.payouts.get(highest, 0)
