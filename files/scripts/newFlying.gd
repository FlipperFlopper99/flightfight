extends CharacterBody3D

# Flight Tuning Variables
@export var thrust_multiplier = 50.0
@export var lift_multiplier = 1.5
@export var drag_multiplier = 0.1
@export var gravity = 5.0
@export var friction = 5.0

# Node References
@export var origin: XROrigin3D
@export var camera: XRCamera3D
@export var leftWing: XRController3D
@export var rightWing: XRController3D

# State Variables
var previous_head_position: Vector3 = Vector3.ZERO
var head_ready: bool = false

func _ready() -> void:
	velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	# Guard against division-by-zero on the very first frame.
	if delta == 0:
		return

	# 1. SET INPUT DIRECTIONS
	# Provide the wings with a stable "inward" direction based on the camera.
	if camera and leftWing and rightWing:
		var player_right_vector = camera.global_transform.basis.x.normalized()
		leftWing.inward_flap_direction = player_right_vector
		rightWing.inward_flap_direction = -player_right_vector

	# 2. APPLY ENVIRONMENTAL FORCES
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 3. CALCULATE FLIGHT FORCES
	# A. Thrust from flapping
	var thrust = Vector3.ZERO
	if leftWing:
		thrust += -leftWing.global_transform.basis.x.normalized() * leftWing.speed_effective
	if rightWing:
		thrust += -rightWing.global_transform.basis.x.normalized() * rightWing.speed_effective
	if leftWing and rightWing:
		thrust /= 2.0
	thrust *= thrust_multiplier

	# B. Aerodynamic Forces (Lift & Drag)
	var lift = Vector3.ZERO
	var drag = Vector3.ZERO
	var airspeed = velocity.length()

	if airspeed > 1.0:
		var airspeed_sq = airspeed * airspeed
		var velocity_dir = velocity / airspeed
		var avg_wing_up = (leftWing.global_transform.basis.y + rightWing.global_transform.basis.y).normalized()
		var angle_of_attack_ratio = avg_wing_up.dot(-velocity_dir)
		
		if angle_of_attack_ratio > 0.0:
			lift = avg_wing_up * (airspeed_sq * angle_of_attack_ratio * lift_multiplier)
		
		var profile_drag = airspeed_sq * angle_of_attack_ratio * drag_multiplier
		var base_drag = airspeed_sq * drag_multiplier * 0.25
		drag = -velocity_dir * (profile_drag + base_drag)

	# 4. CALCULATE & APPLY PHYSICAL MOVEMENT
	var head_velocity = Vector3.ZERO
	if camera:
		var current_head_position = camera.global_transform.origin
		
		# Wait for the first frame to prime the 'previous_head_position'
		if head_ready:
			head_velocity = (current_head_position - previous_head_position) / delta
		else:
			head_ready = true # Set the flag for the next frame
			
		previous_head_position = current_head_position
	
	# This overwrites horizontal velocity. It makes physical movement feel 1-to-1 and responsive.
	velocity.x = head_velocity.x
	velocity.z = head_velocity.z

	# 5. SUM FORCES & APPLY TO VELOCITY
	var total_force = thrust + lift + drag
	velocity += total_force * delta
	
	# If we're on the floor, apply friction *after* all forces are calculated.
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, friction * delta)
		velocity.z = lerp(velocity.z, 0.0, friction * delta)

	# 6. MOVE THE PLAYER
	move_and_slide()

	# 7. POST-PHYSICS RIG SYNC
	# Move the whole VR rig to match the new physics body position.
	if origin:
		origin.global_transform.origin = self.global_transform.origin