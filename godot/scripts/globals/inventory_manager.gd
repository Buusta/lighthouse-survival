extends Node

signal stack_updated(stack: ItemStack, stack_idx: int)
signal cursor_updated(stack: ItemStack)

var inventory_slots: int = 24
var inventory_stacks: Array[ItemStack] = []
var cursor_stack: ItemStack

func _ready() -> void:
	inventory_stacks.resize(inventory_slots)
	for i: int in range(inventory_slots):
		if inventory_stacks[i] == null:
			inventory_stacks[i] = ItemStack.new()

	DevConsole.add_command("debug_inventory", _debug_inventory)
	DevConsole.add_command("debug_inventory_raw", _debug_inventory_raw)

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

### DEPRECATED JUST FOR A BIT!!!
#func add_stack(stack: ItemStack, idx: int = -1) -> bool:
	#if idx == -1:
		#return false
#
	#var inventory_stack: ItemStack = inventory_stacks[idx]
#
	#if inventory_stack.id == -1:
		#inventory_stacks[idx] = stack
		#stack_updated.emit(stack, idx)
		#return true
#
	#var inventory_item_data: ItemData = inventory_stack.item_data[0]
#
	#if inventory_stack.id == stack.id:
		#for item: ItemData in stack.item_data:
			#if inventory_stack.item_data.size() < inventory_item_data.max_stack:
				#inventory_stack.item_data.append(item)
		#stack_updated.emit(inventory_stack, idx)
		#return true
#
	#return false

func remove_stack(idx: int) -> void:
	inventory_stacks[idx] = ItemStack.new()
	stack_updated.emit(inventory_stacks[idx], idx)

func stack_to_cursor(idx: int) -> void:
	cursor_stack = inventory_stacks[idx].duplicate()
	cursor_updated.emit(cursor_stack)
	inventory_stacks[idx] = ItemStack.new()
	stack_updated.emit(inventory_stacks[idx], idx)

### il leave it here but its a mistake
#func single_stack_to_cursor(idx: int) -> void:
	#var inventory_stack: ItemStack = inventory_stacks[idx]
	#cursor_stack = ItemStack.new()
	#cursor_stack.id = inventory_stack.id
	#cursor_stack.item_data.append(inventory_stack.item_data[0])
	#inventory_stack.item_data.pop_front()
	#if inventory_stack.item_data.is_empty():
		#inventory_stacks[idx] = ItemStack.new()
	#stack_updated.emit(inventory_stacks[idx], idx)
	#cursor_updated.emit(cursor_stack)
	#print(cursor_stack.item_data)

func cursor_to_stack(idx: int) -> void:
	if cursor_stack == null:
		push_warning("why are you doing this? this is a silly. this is a silly and a danger")
		return

	var inventory_stack: ItemStack = inventory_stacks[idx]

	if inventory_stack.id == -1:
		inventory_stacks[idx] = cursor_stack
		cursor_stack = null
		stack_updated.emit(inventory_stacks[idx], idx)
		cursor_updated.emit(null)
		return

	if inventory_stack.id == cursor_stack.id:
		var max_stack: int = inventory_stack.item_data[0].max_stack
		while cursor_stack.item_data.size() > 0 and inventory_stack.item_data.size() < max_stack:
			inventory_stack.item_data.append(cursor_stack.item_data.pop_front())

		inventory_stacks[idx] = inventory_stack
		stack_updated.emit(inventory_stacks[idx], idx)
		if cursor_stack.item_data.size() > 0:
			cursor_updated.emit(cursor_stack)
		else:
			cursor_updated.emit(null)
		return

func single_cursor_to_stack(idx: int) -> void:
	if cursor_stack == null or cursor_stack.item_data.is_empty():
		return
	var inventory_stack: ItemStack = inventory_stacks[idx]
	if inventory_stack.id == -1:
		inventory_stack.id = cursor_stack.id
		inventory_stack.item_data.append(cursor_stack.item_data.pop_front())
		if cursor_stack.item_data.is_empty():
			cursor_stack = null
		stack_updated.emit(inventory_stacks[idx], idx)
		cursor_updated.emit(cursor_stack)
		return
	if cursor_stack.id == inventory_stack.id:
		if inventory_stack.item_data.size() < inventory_stack.item_data[0].max_stack:
			inventory_stack.item_data.append(cursor_stack.item_data.pop_front())
			if cursor_stack.item_data.is_empty():
				cursor_stack = null
			stack_updated.emit(inventory_stacks[idx], idx)
			cursor_updated.emit(cursor_stack)

func _debug_inventory(_args: PackedStringArray) -> Variant:
		var id_quant_array: Array = []
		for i: int in range(inventory_stacks.size()):
			var stack: ItemStack = inventory_stacks[i]
			id_quant_array.append([stack.id, stack.item_data.size()])
		return id_quant_array

func _debug_inventory_raw(_args: PackedStringArray) -> Array[ItemStack]:
	return inventory_stacks
