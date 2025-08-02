extends XROrigin3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func process_on_irl_movement(delta):
	var current_velocity = $body.velocity

	var player_body_org = $body.global_transform.origin

	var player_body_location : Vector3 = $XRcamera3D.transform * $XRcamera3D/neck.transform.origin
	player_body_location.y = 0.0
	player_body_location = (global_transform * player_body_location) / delta

	$body.velocity = player_body_location - player_body_org
	$body.move_and_slide()

	$body.velocity = current_velocity

	var movement = player_body_location - $body.global_transform.origin
	movement.y = 0.0
	if movement.length() > 0.01:
		return true
	else:
		return false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var is_colliding = process_on_irl_movement(delta)
