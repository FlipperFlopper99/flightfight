extends XRController3D

var speed_effective : float = 0.0
var inward_flap_direction: Vector3 = Vector3.ZERO

func _physics_process(_delta: float) -> void:
    var primary_interface = XRServer.get_primary_interface()

    if primary_interface == null or not primary_interface.is_initialized():
        speed_effective = 0.0
        return

    var tracker_name

    if self.name.to_lower().contains("left"):
        tracker_name = "/user/hand/left"
    else:
        tracker_name = "/user/hand/right"

    # 1. Access the global XRServer singleton directly.
    # 2. Get the specific XRPositionalTracker object using the controller's tracker name.
    var wing_tracker: XRPositionalTracker = XRServer.get_tracker(tracker_name)
    if wing_tracker == null:
        print("left wing tracker is null")
        speed_effective = 0.0
        return

    # 3. Get the linear_velocity property from the tracker object.
    var tracked_velocity = wing_tracker.linear_velocity

    # 4. The rest of the logic is the same and will now work with real data.
    if inward_flap_direction.is_zero_approx():
        speed_effective = 0.0
        return

    speed_effective = tracked_velocity.dot(inward_flap_direction)

    if speed_effective < 0:
        speed_effective = 0.0
