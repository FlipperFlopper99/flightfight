extends XRNode3D

# flyleft and flyright use the same scripts, so you can just copy this code to both files when updated

var prev_pos : Vector3 = Vector3.ZERO
var current_pos : Vector3 = Vector3.ZERO
var speed_effective : float = 0.0
var speed : float = 0.0
var origin : Node3D
var delta_pos

func _ready() -> void:
    prev_pos = global_transform.origin # make sure to initialize prev_pos
    current_pos = global_transform.origin
    origin = get_parent() # assuming the parent is the origin node

func _physics_process(delta: float) -> void:
    prev_pos = current_pos
    current_pos = global_transform.origin
    delta_pos = current_pos.x - prev_pos.x

    speed = (current_pos - prev_pos).length() / delta

    if delta_pos < 0:
        speed_effective = abs(delta_pos) / delta
    else:
        speed_effective = speed