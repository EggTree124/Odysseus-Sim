extends CharacterBody3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var mouse_sensitivity: float = 0.003
@export var min_pitch: float = -89.0
@export var max_pitch: float = 89.0

@onready var camera_3d: Camera3D = $Node3D/Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Yaw: Rotate character body left/right
		rotate_y(-event.relative.x * mouse_sensitivity)
		# Pitch: Rotate camera up/down
		camera_3d.rotate_x(-event.relative.y * mouse_sensitivity)
		
		# Clamp pitch to prevent flipping upside down
		camera_3d.rotation.x = clamp(
			camera_3d.rotation.x,
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch)
		)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var target_fov := 90 if direction != Vector3.ZERO else 75
	$Node3D/Camera3D.fov = move_toward($Node3D/Camera3D.fov, target_fov, 50.0 * delta) #fov type shits
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
##NOOO
	move_and_slide()
