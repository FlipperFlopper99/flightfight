extends XRController3D

var speed_effective : float = 0.0
var inward_flap_direction: Vector3 = Vector3.ZERO

var previous_position: Vector3 = Vector3.ZERO
var has_run_once: bool = false

func _ready() -> void:
	# No initialization needed here, it's handled in the first physics frame.
	pass

func _physics_process(delta: float) -> void:
	# Guard against division-by-zero on the very first frame.
	if delta == 0:
		return

	var current_position = self.global_transform.origin
	
	# On the first run, we only store the position and skip the velocity calculation
	# to prevent a massive velocity spike from the origin (0,0,0).
	if not has_run_once:
		previous_position = current_position
		has_run_once = true
		speed_effective = 0.0
		return

	# Calculate velocity manually: (current_pos - last_pos) / time
	var tracked_velocity = (current_position - previous_position) / delta
	
	# Update the position for the next frame.
	previous_position = current_position

	# Project the velocity onto the "inward flap" direction provided by the body.
	if inward_flap_direction.is_zero_approx():
		speed_effective = 0.0
		return
		
	speed_effective = tracked_velocity.dot(inward_flap_direction)
	
	if speed_effective < 0:
		speed_effective = 0.0