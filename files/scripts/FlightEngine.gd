extends CharacterBody3D

@export_range(5.0, 50.0, 1.0) var thrust_power: float = 20.0 
@export_range(0.1, 5.0, 0.1) var lift_multiplier: float = 0.5
@export_range(0.05, 1.0, 0.05) var drag_multiplier: float = 0.1
@export_range(1.0, 10.0, 0.5) var gravity: float = 5.0
@export_range(1.0, 5.0, 0.5) var friction: float = 2.0

@export var origin: XROrigin3D
@export var camera: XRCamera3D
@export var leftWing: XRController3D
@export var rightWing: XRController3D

func _ready() -> void:
	velocity = Vector3.ZERO

func _wing_force(controller: XRController3D, palm_direction: float) -> Vector3:
	if controller == null or origin == null:
		return Vector3.ZERO
	var local_vel = controller.current_local_velocity
	var global_vel = origin.global_transform.basis * local_vel
	var palm = origin.global_transform.basis.x * palm_direction
	var push = global_vel.dot(palm)
	return palm * (-push * abs(push) * thrust_power)

func _physics_process(delta: float) -> void:
	if delta <= 0:
		return
	var primary_interface = XRServer.get_primary_interface()
	if primary_interface == null or not primary_interface.is_initialized():
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	var flying_force = _wing_force(leftWing, 1.0) + _wing_force(rightWing, -1.0)

	var airspeed = velocity.length()
	var lift = Vector3.ZERO
	var drag = Vector3.ZERO

	if airspeed > 1.0:
		var airspeed_sq = airspeed * airspeed
		var velocity_dir = velocity / airspeed

		var leftUp = leftWing.global_transform.basis.y
		var rightUp = rightWing.global_transform.basis.y
		var avg_wing_up = (leftUp + rightUp) / 2

		if avg_wing_up == Vector3.ZERO:
			avg_wing_up = Vector3.UP
		else:
			avg_wing_up = avg_wing_up.normalized()

		var angle_of_attack = avg_wing_up.dot(-velocity_dir)
		if angle_of_attack > 0.0:
			lift = avg_wing_up * (airspeed_sq * angle_of_attack * lift_multiplier)
		drag = -velocity_dir * (airspeed_sq * drag_multiplier)

	if flying_force < 0:
		flying_force = Vector3.ZERO

	var total_force = flying_force + lift + drag
	velocity += total_force * delta

	if is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, friction * delta)
		velocity.z = lerp(velocity.z, 0.0, friction * delta)

	move_and_slide()