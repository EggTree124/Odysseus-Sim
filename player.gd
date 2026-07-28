extends CharacterBody3D

const SPEED = 30.0
const JUMP_VELOCITY = 10.0

@export var mouse_sensitivity: float = 0.003
@export var min_pitch: float = -89.0
@export var max_pitch: float = 89.0

@onready var camera_3d: Camera3D = $Node3D/Camera3D
var attacking = false
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

	# Get input direction and translate relative to body rotation
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var target_fov := 90 if direction != Vector3.ZERO else 75
	$Node3D/Camera3D.fov = move_toward($Node3D/Camera3D.fov, target_fov, 65.0 * delta)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if Input.is_action_just_pressed("swing") and !attacking:
		attacking = true
		$human_unpacked/AnimationPlayer.play("slash")

	if !attacking:
		if direction:
			$human_unpacked/AnimationPlayer.speed_scale = 1.5
			$human_unpacked/AnimationPlayer.play("walk")
		else:
			$human_unpacked/AnimationPlayer.stop()

	move_and_slide()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "slash":
		attacking = false
