extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5



const MOUSE_SENSITIVITY = 0.003

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

@onready var cam_rig = $CamRig
@onready var spring_arm = $CamRig/SpringArm3D

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# 1. Rotate the RIG left/right (Yaw)
		cam_rig.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		# 2. Rotate the SPRING ARM up/down (Pitch)
		# We rotate the child node independently so it never affects the parent's axis
		spring_arm.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		
		# 3. Clamp the Pitch (prevent backflips)
		# We clamp the SpringArm's rotation, not the Rig's
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-90), deg_to_rad(30))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, cam_rig.rotation.y)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
