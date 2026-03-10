@tool
extends TextureRect

#@export var radius: float = 20.0
@export var color: Color = Color.WHITE:
	set(p_color):
		if p_color != color:
			color = p_color
			_modulate()
@export var thickness: int = 2
@export var crosshair_size: int = 100
@export var inner_radius_ratio: float = 0.5 
@export var transparency: float = 0.5:
	set(p_transparency):
		if p_transparency != transparency:
			transparency = p_transparency
			_modulate()
@export var update: bool = false:
	set(p_update):
		update_crosshair()
		update = false

func update_crosshair() -> void:
	var img: Image = Image.create(crosshair_size, crosshair_size, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	
	var center: Vector2 = Vector2(crosshair_size / 2.0, crosshair_size / 2.0)
	var outer_radius: float = crosshair_size / 2.0
	var inner_radius: float = outer_radius * inner_radius_ratio
	
	for x in range(crosshair_size):
		for y in range(crosshair_size):
			var dist: float = center.distance_to(Vector2(x, y))
			if dist <= outer_radius and dist >= inner_radius:
				img.set_pixel(x, y, color)
	
	texture = ImageTexture.create_from_image(img)
	custom_minimum_size = Vector2(crosshair_size, crosshair_size)
	pivot_offset = Vector2(crosshair_size / 2.0, crosshair_size / 2.0)

func _modulate() -> void:
	modulate = Color(color.r, color.g, color.b, transparency)
