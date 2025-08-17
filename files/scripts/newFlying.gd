extends CharacterBody3D

# Change these values to get the flight feel you want!
const THRUST_MULTIPLIER = 70.0 # Makes your flapping powerful. TRY 20 to 50.
const LIFT_MULTIPLIER = 1.5    # How much lift you get from speed. TRY 1.0 to 3.0.
const DRAG_MULTIPLIER = 0.1    # Air resistance. TRY 0.1 to 0.5.
const GRAVITY = 5
const FRICTION = 5

var origin: XROrigin3D
var camera: XRCamera3D
var leftWing: XRController3D
var rightWing: XRController3D

func _ready() -> void:
	velocity = Vector3.ZERO
	origin = get_node("XROrigin3D")
	camera = get_node("XROrigin3D/XRCamera3D")
	leftWing = get_node("XROrigin3D/left controller")
	rightWing = get_node("XROrigin3D/right controller")

func _physics_process(delta: float) -> void:
	# Sync collider with headset position
	if origin and camera:
		var camera_offset_xz = camera.global_transform.origin - origin.global_transform.origin
		camera_offset_xz.y = 0
		global_transform.origin += camera_offset_xz
		origin.global_transform.origin -= camera_offset_xz
	
	# Set flap directions based on camera
	if camera and leftWing and rightWing:
		var player_right_vector = camera.global_transform.basis.x.normalized()
		leftWing.inward_flap_direction = player_right_vector
		rightWing.inward_flap_direction = -player_right_vector # Basically player_left_vector

	# 1. APPLY GRAVITY AND GROUND FRICTION
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
		velocity.z = lerp(velocity.z, 0.0, FRICTION * delta)
	else:
		velocity.y -= GRAVITY * delta

	# 2. CALCULATE THRUST FROM FLAPPING
	var thrust = Vector3.ZERO
	if leftWing:
		thrust += -leftWing.global_transform.basis.x.normalized() * leftWing.speed_effective
	if rightWing:
		thrust += -rightWing.global_transform.basis.x.normalized() * rightWing.speed_effective
	if leftWing and rightWing:
		thrust /= 2.0
	
	# Apply the multiplier to make thrust powerful enough
	thrust *= THRUST_MULTIPLIER

	# 3. APPLY LIFT AND DRAG
	var lift = Vector3.ZERO
	var drag = Vector3.ZERO
	var airspeed = velocity.length()

	# Only calculate aero forces if moving at a meaningful speed
	if airspeed > 1.0:
		var airspeed_sq = airspeed * airspeed
		var velocity_dir = velocity / airspeed # More efficient than .normalized()

		# Get the average "up" direction of the wings
		var avg_wing_up = (leftWing.global_transform.basis.y + rightWing.global_transform.basis.y).normalized()

		# A. Lift Calculation (based on Angle of Attack)
		# How much the wing's top surface is pushing against the oncoming air
		var angle_of_attack_ratio = avg_wing_up.dot(-velocity_dir)
		
		# Only generate lift when angled correctly
		if angle_of_attack_ratio > 0.0:
			var lift_magnitude = airspeed_sq * angle_of_attack_ratio * LIFT_MULTIPLIER
			lift = avg_wing_up * lift_magnitude
		
		# B. Drag Calculation (Simplified)
		# Drag always pushes directly against the direction of velocity
		var drag_magnitude = airspeed_sq * DRAG_MULTIPLIER
		drag = -velocity_dir * drag_magnitude

	# 4. SUM ALL FORCES and APPLY TO VELOCITY
	var total_force = thrust + lift + drag
	velocity += total_force * delta
	
	# 5. MOVE THE PLAYER
	move_and_slide()