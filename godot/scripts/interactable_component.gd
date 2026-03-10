class_name InteractableComponent extends Area3D

signal interacted(interactor: Player)

func interact(interactor: Player) -> void:
	interacted.emit(interactor)
