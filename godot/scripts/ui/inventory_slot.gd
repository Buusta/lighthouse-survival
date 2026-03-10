class_name InventorySlot extends PanelContainer

@onready var icon_texture: TextureRect = $Icon
@onready var quantity_label: Label = $InfoVBox/QuantityHBox/QuantityLabel

var item_stack: ItemStack

func update_stack(stack: ItemStack) -> void:
	item_stack = stack
	if stack.item_data.size() < 1:
		icon_texture.texture = null
		quantity_label.text = ""

	var item_data: ItemData = item_stack.item_data[0]
	icon_texture.texture = item_data.icon
	quantity_label.text = str(item_stack.item_data.size())
