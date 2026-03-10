class_name ConsumableEffect extends Resource

enum EffectType {
	HUNGER,
	HYDRATION
}

@export var type: EffectType
@export var value: float
