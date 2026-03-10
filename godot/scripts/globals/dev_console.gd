extends Node

signal output(text: String)

var commands: Dictionary = {}

func _ready() -> void:
	add_command("print", _dev_console_print, 1)

func add_command(comm: String, callable: Callable, args_count: int = 0) -> void:
	commands[comm] = [callable, args_count]

func get_suggestions(current: String) -> Array[String]:
	var suggestions: Array[String] = []
	for key: String in commands.keys():
		if key.begins_with(current):
			suggestions.append(key)
	return suggestions

func execute(input: String) -> void:
	var parts: PackedStringArray = parse_args(input)
	var command: String = parts[0]
	var args: PackedStringArray = parts.slice(1)
	output.emit(">>> " + input)
	if commands.has(command):
		var expected: int = commands[command][1]
		if args.size() != expected:
			output.emit("expected %d args, got %d" % [expected, args.size()])
			return

		var result: Variant = commands[command][0].call(args)
		if result != null:
			output.emit(str(result) + "\n")
	else:
		output.emit("unknown command: " + command)

func parse_args(input: String) -> PackedStringArray:
	var result: PackedStringArray = []
	var current: String = ""
	var in_quotes: bool = false
	for c: String in input:
		if c == '"':
			in_quotes = !in_quotes
		elif c == ' ' and not in_quotes:
			if current.length() > 0:
				result.append(current)
				current = ""
		else:
			current += c
	if current.length() > 0:
		result.append(current)
	return result

func _dev_console_print(args: PackedStringArray) -> String:
	return args[0]
