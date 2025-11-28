extends XRController3D

var current_local_velocity: Vector3 = Vector3.ZERO
var previous_local_position: Vector3 = Vector3.ZERO
var was_tracking: bool = false

func _physics_process(delta: float) -> void:
	var primary_interface = XRServer.get_primary_interface()
	if primary_interface == null or not primary_interface.is_initialized() or delta == 0 or not get_has_tracking_data():
		current_local_velocity = Vector3.ZERO
		was_tracking = false
		previous_local_position = position
		return

	var current_local_position = position

	if was_tracking:
		current_local_velocity = (current_local_position - previous_local_position) / delta
	else:
		was_tracking = true

	previous_local_position = current_local_position