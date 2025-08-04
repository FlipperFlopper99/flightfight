extends XRNode3D
#left controller

#variables
var prev_pos : Vector3 = Vector3.ZERO
var current_pos : Vector3 = Vector3.ZERO
var speed : float = 0.0
var speed_effective : float = 0.0
var flap_direction : Vector3 = Vector3.ZERO

#initalize
func _ready() -> void:
    prev_pos = global_transform.origin
    current_pos = global_transform.origin

#speed
func _physics_process(delta: float) -> void:
    prev_pos = current_pos
    current_pos = global_transform.origin
    var velocity_vector = (current_pos - prev_pos) / delta
    speed = velocity_vector.length()

    if flap_direction.is_zero_approx():
        speed_effective = 0.0
        return

    speed_effective = velocity_vector.dot(flap_direction)

    if speed_effective < 0.0:
        speed_effective = 0.0