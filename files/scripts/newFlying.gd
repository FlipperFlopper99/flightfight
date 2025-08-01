extends CharacterBody3D

var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")
const DRAG = 0.5
const LIFT = 1.0

var leftWing: Node3D
var rightWing: Node3D


func _ready() -> void:
	velocity = Vector3.ZERO
	leftWing = get_node("../left controller")
	rightWing = get_node("../right controller")

func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	
	# thrust from wings using their local -x axis directions
	var thrust: Vector3 = Vector3.ZERO
	if leftWing:
		var left_thrust = -leftWing.global_transform.basis.x.normalized() * leftWing.speed_effective
		thrust += left_thrust
	if rightWing:
		var right_thrust = -rightWing.global_transform.basis.x.normalized() * rightWing.speed_effective
		thrust += right_thrust
	thrust /= 2.0
	velocity += thrust * delta
	
	# Dynamic drag: increases with wing pitch deviation toward 90° or -90°
	var drag_multiplier = 1.0
	if leftWing or rightWing:
		var pitch_left = 0.0
		if leftWing:
			pitch_left = abs(rad_to_deg((leftWing.rotation.x)))
		var pitch_right = 0.0
		if rightWing:
			pitch_right = abs(rad_to_deg((rightWing.rotation.x)))
		var max_pitch = max(pitch_left, pitch_right)
		drag_multiplier = 1.0 + (max_pitch / 90.0)  # 1 to 2 range
	velocity -= velocity * DRAG * drag_multiplier * delta
	
	# Lift: computed from average wing pitch (clamped to ±90°)
	var lift_force = 0.0
	if leftWing or rightWing:
		var pitch_avg = 0.0
		var count = 0
		if leftWing:
			pitch_avg += clamp(rad_to_deg(leftWing.rotation.x), -90, 90)
			count += 1
		if rightWing:
			pitch_avg += clamp(rad_to_deg(rightWing.rotation.x), -90, 90)
			count += 1
		if count > 0:
			pitch_avg /= count
			lift_force = LIFT * sin(deg_to_rad(pitch_avg))
	velocity.y += lift_force * delta
	
	# No rotation adjustments to preserve collision behavior
	move_and_slide()
