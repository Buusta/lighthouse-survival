extends Node

signal stack_updated(stack: ItemStack, stack_idx: int)

var inventory_slots: int = 4
var inventory_stacks: Array[ItemStack] = []

func _ready() -> void:
	inventory_stacks.resize(inventory_slots)
	for i: int in range(inventory_slots):
		if inventory_stacks[i] == null:
			inventory_stacks[i] = ItemStack.new()

	DevConsole.add_command("debug_inventory", _debug_inventory)

func add_item(item_data: ItemData) -> bool:
	var empty_stack_idx: int = -1

	for i: int in range(inventory_slots):
		var stack: ItemStack = inventory_stacks[i]

		if stack.id == -1 && empty_stack_idx == -1:
			empty_stack_idx = i
			continue

		if stack.id == item_data.id:
			if stack.item_data.size() < item_data.max_stack:
				stack.item_data.append(item_data)
				stack_updated.emit(stack, i)
				return true

	if empty_stack_idx != -1:
		inventory_stacks[empty_stack_idx].id = item_data.id
		inventory_stacks[empty_stack_idx].item_data.append(item_data)
		stack_updated.emit(inventory_stacks[empty_stack_idx], empty_stack_idx)
		return true

	return false

func _debug_inventory(_args: PackedStringArray) -> Variant:
		var id_quant_array: Array = []
		for i: int in range(inventory_stacks.size()):
			var stack: ItemStack = inventory_stacks[i]
			id_quant_array.append([stack.id, stack.item_data.size()])
		return id_quant_array
