class_name Player extends CharacterBody3D

@export var sensitivity: float = 1.0
@export var head: Node3D
@export var interaction_ray: RayCast3D
@export var keyboard_input_component: KeyboardInputComponent
@export var camera: Camera3D

@export_category("Movement")
@export var walk_speed: float = 3.0
@export var sprint_speed: float = 4.75
@export var acceleration: float = 30000.0
@export var deceleration: float = 30000.0
@export var jump_velocity: float = 4.0
@export var air_velocity: float = 2.0
@export var air_acceleration: float = 1.0
@export var air_deceleration: float = 2.0

var input_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	DevConsole.add_command("walk_speed", _set_walk_speed, 1)

func _set_walk_speed(args: PackedStringArray) -> float:
	var speed: float = float(args[0])
	walk_speed = speed
	return walk_speed

func _process(_delta: float) -> void:
	input_vector = keyboard_input_component.input_vector

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

	if interaction_ray.is_colliding() and Input.is_action_just_pressed("interact"):
		var interactable: InteractableComponent = interaction_ray.get_collider()
		interactable.interact(self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensitivity / 1000.0)
		head.rotate_x(-event.relative.y * sensitivity / 1000.0)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	if event.is_action_pressed("exit"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).is_pressed():
			var camera_tween: Tween = create_tween()
			camera_tween.set_ease(Tween.EASE_IN_OUT)
			camera_tween.tween_property(camera, "fov", 50.0, .3)
		else:
			var camera_tween: Tween = create_tween()
			camera_tween.set_ease(Tween.EASE_IN_OUT)
			camera_tween.tween_property(camera, "fov", 75.0, .3)

func move(delta: float, movement_speed: float, accel: float) -> void:
	var local_vel: Vector3 = transform.basis.inverse() * velocity
	#var direction: Vector3 = (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	var local_dir: Vector3 = Vector3(input_vector.x, 0, input_vector.y).normalized() if input_vector.length() > 0.01 else Vector3.ZERO

	local_vel.x = move_toward(local_vel.x, local_dir.x * movement_speed, delta * accel)
	local_vel.z = move_toward(local_vel.z, local_dir.z * movement_speed, delta * accel)

	velocity.x = (transform.basis * local_vel).x
	velocity.z = (transform.basis * local_vel).z

func jump() -> void:
	if is_on_floor():
		velocity.y = jump_velocity
