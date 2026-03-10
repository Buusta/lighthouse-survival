class_name ItemComponent extends Node

@export var parent: Node3D
@export var item_data: ItemData

# Called when the node enters the scene tree for the first time.
func _interacted(_interactor: Player) -> void:
	var added_to_inv: bool = InventoryManager.add_item(item_data)
	if added_to_inv:
		parent.queue_free()
