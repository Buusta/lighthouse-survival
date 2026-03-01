class_name Player extends CharacterBody3D

@export var sensitivity: float = 1.0
@export var head: Node3D

@export_category("Movement")
@export var walk_speed: float = 3.0
@export var sprint_speed: float = 4.75

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		jump(JUMP_VELOCITY)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity / 1000.0)
		head.rotate_x(-event.relative.y * sensitivity / 1000.0)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func move(movement_speed: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.z = move_toward(velocity.z, 0, movement_speed)

func jump(jump_velocity: float) -> void:
	velocity.y = jump_velocity
