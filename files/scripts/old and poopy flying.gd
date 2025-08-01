extends Node3D

var leftWing: Node3D
var rightWing: Node3D
var camera_node
var velocity: Vector3 = Vector3.ZERO
var acceleration: float = 0.0

func _ready() -> void:
	leftWing = get_node("../left controller") # initializes the controller values
	rightWing = get_node("../right controller")

func _physics_process(delta: float) -> void:
	if leftWing and rightWing: # only run if both wings are present
		var avg_rotation = (leftWing.rotation + rightWing.rotation) / 2.0 # calculate average rotation
		avg_rotation.y += avg_rotation.z # adds roll to the yaw, as roll is not needed in this game
		avg_rotation.clamp(Vector3(-85, 360, 360), Vector3(85, 360, 360)) # limit pitch to prevent excessive tilting
		set_rotation(avg_rotation)

		velocity -= velocity * delta # adds deceleration/drag to the velocity

		acceleration = (leftWing.speed_effective + rightWing.speed_effective) * 1.5 # adds the effective speed of both wings
		velocity += -basis.z * acceleration * delta # only adds forward acceleration
		transform.origin += velocity * delta # actually moves the node
		