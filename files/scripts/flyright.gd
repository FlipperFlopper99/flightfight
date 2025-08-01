extends XRNode3D

# flyleft and flyright use the exact same script, so you can just copy this code to both files when updated

var prev_pos : Vector3 = Vector3.ZERO
var current_pos : Vector3 = Vector3.ZERO
var speed_effective : float = 0.0 # what the final processed speed will be
var speed : float = 0.0 #raw speed (or velocity)
var origin : Node3D # the parent node that this node is attached to, used for relative movement
var delta_pos # the speed only in the x direction

func _ready() -> void:
    prev_pos = global_transform.origin # make sure to initialize positions
    current_pos = global_transform.origin
    origin = get_parent() # the parent is the origin node

func _physics_process(delta: float) -> void:
    prev_pos = current_pos
    current_pos = global_transform.origin # update current position values
    delta_pos = current_pos.x - prev_pos.x # calculate the change in position in the x direction

    speed = (current_pos - prev_pos).length() / delta

    if delta_pos < 0:
        speed_effective = abs(delta_pos) / delta # the final processed speed
    else:
        speed_effective = 0.0 # if moving backwards, speed_effective is 0