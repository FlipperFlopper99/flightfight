extends CharacterBody3D
#body node

#constants
var GRAVITY =  ProjectSettings.get_setting("physics/3d/default_gravity")
const DRAG = 0.5
const LIFT = 1

#variables
var origin: XROrigin3D
var camera: XRCamera3D
var leftWing: XRController3D
var rightWing: XRController3D

#initalize
func _ready() -> void:
	origin = get_node("XROrigin3D")
	camera = get_node("XROrigin3D/XRCamera3D")
	leftWing = get_node("XROrigin3D/left controller")
	rightWing = get_node("XROrigin3D/right controller")

#fly
func _physics_process(delta: float) -> void:
	#fix offset
	if origin and camera:
		var offset = origin.global_transform.origin - camera.global_transform.origin
		offset.y = 0.0
		global_transform.origin += offset
		origin.global_transform.origin -= offset

	#get direction
	if camera and leftWing and rightWing:
		var camera_direction = camera.global_transform.basis.x.normalized()
		leftWing.flap_direction = camera_direction
		rightWing.flap_direction = -camera_direction

	#gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	#thrust
	var thrust: Vector3 = Vector3.ZERO
	if leftWing:
		var left_thrust = -leftWing.global_transform.basis.x.normalized() * leftWing.speed_effective
		thrust += left_thrust
	if rightWing:
		var right_thrust = rightWing.global_transform.basis.x.normalized() * rightWing.speed_effective
		thrust += right_thrust
	if leftWing and rightWing:
		thrust /= 2.0

	velocity += thrust * delta

	#drag
	var drag_force = 0.0
	if leftWing or rightWing:
		var pitch_left = abs(rad_to_deg(leftWing.rotation.x))
		var pitch_right = abs(rad_to_deg(rightWing.rotation.x))
		var max_pitch = max(pitch_left, pitch_right)
		drag_force = (max_pitch / 90.0) + 1

		velocity = velocity.lerp(Vector3.ZERO, drag_force * DRAG * delta)

	#lift
	var lift_force = 0.0
	if leftWing or rightWing:
		var avg_pitch = 0.0
		var count = 0
		if leftWing:
			avg_pitch += clamp(leftWing.rotation_degrees.x, -90, 90); count += 1
		if rightWing:
			avg_pitch += clamp(rightWing.rotation_degrees.x, -90, 90); count += 1
		if count > 0:
			avg_pitch /= count
			lift_force = LIFT * -sin(deg_to_rad(avg_pitch))

		velocity.y += lift_force

	#move
	move_and_slide()