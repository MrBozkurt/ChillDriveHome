extends VehicleBody3D

#Max steer angle in degrees
@export var max_steer : float = 23
@export var steer_speed : float = 0.5
@export var brake_force : float = 1
@export var camera_turn : float = 0.2
## X axis is speed of car in km/h. Y is the engine power in that speed.
@export var power_curve : Curve

#Watch variables
@export var speed : float = 0.0
@export var angle_of_attack : float

@onready var camera_pivot: Marker3D = $CameraPivot

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	speed = linear_velocity.length() * 3.6
	steering = move_toward(steering, Input.get_axis("right", "left") * deg_to_rad(max_steer), delta * steer_speed)
	camera_pivot.rotation.y = steering / deg_to_rad(max_steer) * camera_turn
	#Speed is multiplied with 3.6 to convert it to km/h
	var front_vector := global_basis * Vector3.RIGHT
	angle_of_attack = linear_velocity.dot(front_vector)
	#Directional brake logic.
	#When opposite direction pressed it brakes instead of powering wheels.
	if angle_of_attack >= 0:
		engine_force = Input.get_action_strength("foward") * power_curve.sample(linear_velocity.length() * 3.6)
		brake = Input.get_action_strength("back") * brake_force
	if angle_of_attack <= 0:
		engine_force = -Input.get_action_strength("back") * power_curve.sample(linear_velocity.length() * 3.6)
		brake = Input.get_action_strength("foward") * brake_force
	if speed < 10:
		engine_force = Input.get_axis("back", "foward") * power_curve.sample(linear_velocity.length() * 3.6)
		brake = 0
	if Input.get_action_strength("brake") > 0:
		brake = Input.get_action_strength("brake") * brake_force * 2
