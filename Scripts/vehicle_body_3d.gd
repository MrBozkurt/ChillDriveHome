extends VehicleBody3D

@export var MAX_STEER : float = 0.4
@export var ENGINE_POWER : float = 100
@export var BRAKE_FORCE : float = 1
@export var CAMERA_TURN : float = 0.2
@onready var camera_pivot: Marker3D = $CameraPivot

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("right", "left") * MAX_STEER, delta * 0.5)
	camera_pivot.rotation.y = steering / MAX_STEER * deg_to_rad(23) * CAMERA_TURN
	engine_force = Input.get_axis("back", "foward") * ENGINE_POWER
	brake = Input.get_action_strength("brake") * BRAKE_FORCE
