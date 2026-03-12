class_name CursorSlot extends PanelContainer

@onready var icon_texture: TextureRect = $Icon
@onready var quantity_label: Label = $InfoVBox/QuantityHBox/QuantityLabel

var item_stack: ItemStack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	InventoryManager.cursor_updated.connect(_cursor_stack_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	global_position = mouse_pos - size / 2

func _cursor_stack_updated(stack: ItemStack) -> void:
	if stack == null:
		item_stack = null
		icon_texture.texture = null
		quantity_label.text = ""
		return

	item_stack = stack
	icon_texture.texture = stack.item_data[0].icon
	quantity_label.text = str(stack.item_data.size())
