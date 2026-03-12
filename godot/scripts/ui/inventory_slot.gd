class_name InventorySlot extends PanelContainer

signal interacted(event: InputEventMouseButton, idx: int)

@onready var icon_texture: TextureRect = $Icon
@onready var quantity_label: Label = $InfoVBox/QuantityHBox/QuantityLabel
@onready var slot_button: Button = $SlotButton

var item_stack: ItemStack = ItemStack.new()
var idx: int = -1

func update_stack(stack: ItemStack) -> void:
	if stack.id == -1:
		item_stack = ItemStack.new()
		icon_texture.texture = null
		quantity_label.text = ""
		return

	item_stack = stack
	var item_data: ItemData = stack.item_data[0]

	icon_texture.texture = item_data.icon
	quantity_label.text = str(item_stack.item_data.size())

func _button_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		interacted.emit(mouse_event, idx)
