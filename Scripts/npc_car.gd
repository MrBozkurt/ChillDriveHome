extends VehicleBody3D
class_name NPCCar

@export var target_pos : Marker3D
@export var max_steering_angle : float = 23
@export var steer_speed : float = 1.5
@export var power_curve : Curve
@export var minimum_pursuit_distance : float = 5
@export_enum("Normal:0", "Distracted:1", "Brake Cheker:2", "Overtake preventer:3", "Rear ender:4") var insanity_level : int = 0

#Those variables exist to watch whats going on with this node
@export_category("Watching variables")
@export var waypoint_position : Vector3 = Vector3.ZERO
var reached_destination : bool = false

@export_category("PID Coefficients")
@export_range(0.0, 20.0, 0.01) var kp := 0.91 #0.91
@export_range(0.0, 1.0, 0.000001) var ki := 0.000013
@export_range(0.0, 20.0, 0.01) var kd := 2.11 #2.2
@export var integral_active_zone : float = 0.9
var error : float
var errorTotal : float
var last_error : float
var propotion : float
var integral : float
var derivative : float

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	navigation_agent_3d.target_position = target_pos.global_position
	var insanity := 0.8
	if insanity < 0.5:
		insanity_level = 0
	elif insanity < 0.75:
		insanity_level = 1
	elif insanity < 0.9:
		insanity_level = 2
		$InsanityModeDetectors/BrakeCheck/CollisionShape3D.disabled = false
	elif insanity < 0.95:
		insanity_level = 3
		$InsanityModeDetectors/Overtake/CollisionShape3D.disabled = false
		$InsanityModeDetectors/Overtake/CollisionShape3D2.disabled = false
	else:
		insanity_level = 4
		$InsanityModeDetectors/RearEnd/CollisionShape3D.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pid_controller(delta)
	if reached_destination:
		brake = 2.0
		engine_force = 0.0
		steering = 0.0

func pid_controller(delta: float):
	var waypoint := pure_pursuit()
	var front_direction : Vector3 = ($FrontMarker.global_position - global_position).normalized()
	var waypoint_direction := (waypoint - global_position).normalized()
	var angle_to_waypoint = front_direction.angle_to(waypoint_direction)
	angle_to_waypoint = angle_to_waypoint if front_direction.cross(waypoint_direction).y > 0 else -angle_to_waypoint
	
	error = angle_to_waypoint - steering
	
	if error < integral_active_zone && error != 0:
		errorTotal += error
	else:
		errorTotal = 0
	
	if errorTotal > 50 / ki:
		errorTotal = 50 / ki
	
	if error == 0:
		derivative = 0
	
	propotion = error * kp
	integral = errorTotal * ki
	derivative = (error - last_error) * kd
	last_error = error
	
	var target_steering = clampf(propotion + integral + derivative, -deg_to_rad(max_steering_angle), +deg_to_rad(max_steering_angle))
	
	steering = move_toward(steering, target_steering, delta * steer_speed)
	engine_force = power_curve.sample(linear_velocity.length())

func pure_pursuit() -> Vector3:
	var current_waypoint := navigation_agent_3d.get_next_path_position()
	var distance := global_position.distance_to(current_waypoint)
	var current_index := navigation_agent_3d.get_current_navigation_path_index()
	while distance < minimum_pursuit_distance:
		current_index += 1
		if navigation_agent_3d.get_current_navigation_path().size() <= current_index:
			break
		current_waypoint = navigation_agent_3d.get_current_navigation_path()[current_index]
		distance = global_position.distance_to(current_waypoint)
	return current_waypoint

func _on_target_reached() -> void:
	reached_destination = true


func _on_brake_check_body_entered(_body: Node3D) -> void:
	brake = 10


func _on_overtake_body_entered(_body: Node3D) -> void:
	pass # Replace with function body.


func _on_rear_end_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
