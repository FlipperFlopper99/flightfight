extends Node3D

var leftWing: Node3D
var rightWing: Node3D
var camera_node
var velocity: Vector3 = Vector3.ZERO
var acceleration: float = 0.0

func _ready() -> void:
	leftWing = get_node("../left controller")
	rightWing = get_node("../right controller")

func _physics_process(delta: float) -> void:
	if leftWing and rightWing:
		var avg_rotation = (leftWing.rotation + rightWing.rotation) / 2.0
		avg_rotation.y += avg_rotation.z
		avg_rotation.clamp(Vector3(-85, 360, 360), Vector3(85, 360, 360)) # limit pitch to prevent excessive tilting
		set_rotation(avg_rotation)

		velocity -= velocity * delta

		acceleration = (leftWing.speed_effective + rightWing.speed_effective) * 1.5
		velocity += -basis.z * acceleration * delta
		#velocity = clamp(velocity, -Vector3(10, 10, 10), Vector3(10, 10, 10))
		transform.origin += velocity * delta 
		