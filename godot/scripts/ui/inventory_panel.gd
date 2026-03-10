extends Control

@onready var inventory_slot_scene: PackedScene = load("res://scenes/ui/inventory_slot.tscn")
@onready var grid_container: GridContainer = $GridContainer

var inventory_slots: Array[InventorySlot]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	InventoryManager.stack_updated.connect(_stack_updated)
	for i: int in range(InventoryManager.inventory_slots):
		var slot: InventorySlot = inventory_slot_scene.instantiate()
		grid_container.add_child(slot)
		inventory_slots.append(slot)

func _stack_updated(stack: ItemStack, stack_idx: int) -> void:
	inventory_slots[stack_idx].update_stack(stack)
