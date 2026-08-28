extends VehicleBody3D

#Max steer angle in degrees
@export var MAX_STEER : float = 23
@export var STEER_SPEED : float = 0.5
@export var BRAKE_FORCE : float = 1
@export var CAMERA_TURN : float = 0.2
## X axis is speed of car in km/h. Y is the engine power in that speed.
@export var POWER_CURVE : Curve

#Watch variables
@export var speed : float = 0.0
@export var angle_of_attack : float

@onready var camera_pivot: Marker3D = $CameraPivot

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	speed = linear_velocity.length() * 3.6
	steering = move_toward(steering, Input.get_axis("right", "left") * deg_to_rad(MAX_STEER), delta * STEER_SPEED)
	camera_pivot.rotation.y = steering / deg_to_rad(MAX_STEER) * CAMERA_TURN
	#Speed is multiplied with 3.6 to convert it to km/h
	var front_vector := global_basis * Vector3.RIGHT
	angle_of_attack = linear_velocity.dot(front_vector)
	#Directional brake logic.
	#When opposite direction pressed it brakes instead of powering wheels.
	if angle_of_attack >= 0:
		engine_force = Input.get_action_strength("foward") * POWER_CURVE.sample(linear_velocity.length() * 3.6)
		brake = Input.get_action_strength("back") * BRAKE_FORCE
	else:
		engine_force = Input.get_action_strength("back") * POWER_CURVE.sample(linear_velocity.length() * 3.6)
		brake = Input.get_action_strength("foward") * BRAKE_FORCE
	engine_force = Input.get_axis("back", "foward") * POWER_CURVE.sample(linear_velocity.length() * 3.6)
	brake = Input.get_action_strength("brake") * BRAKE_FORCE
