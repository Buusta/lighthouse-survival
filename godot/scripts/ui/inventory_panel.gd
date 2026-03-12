extends Control

@onready var inventory_slot_scene: PackedScene = load("res://scenes/ui/inventory_slot.tscn")
@onready var grid_container: GridContainer = $GridContainer
@onready var cursor_slot: CursorSlot = $CursorSlot

var inventory_slots: Array[InventorySlot]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	InventoryManager.stack_updated.connect(_stack_updated)
	for i: int in range(InventoryManager.inventory_slots):
		var slot: InventorySlot = inventory_slot_scene.instantiate()
		slot.idx = i
		slot.interacted.connect(_slot_interacted)
		grid_container.add_child(slot)
		inventory_slots.append(slot)

func _stack_updated(stack: ItemStack, stack_idx: int) -> void:
	inventory_slots[stack_idx].update_stack(stack)

func _slot_interacted(event: InputEventMouseButton, idx: int) -> void:
	if not event.pressed:
		return

	var slot: InventorySlot = inventory_slots[idx]

	if cursor_slot.item_stack == null:
		if slot.item_stack.id != -1:
			InventoryManager.stack_to_cursor(idx)
		return

	if slot.item_stack.id == -1:
		if event.button_index == 1:
			InventoryManager.cursor_to_stack(idx)
		else:
			InventoryManager.single_cursor_to_stack(idx)
		return

	if slot.item_stack.id == cursor_slot.item_stack.id:
		if event.button_index == 1:
			InventoryManager.cursor_to_stack(idx)
		else:
			InventoryManager.single_cursor_to_stack(idx)
