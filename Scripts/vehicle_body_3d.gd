extends VehicleBody3D

#Max steer angle in degrees
@export var max_steer : float = 23
@export var steer_speed : float = 0.5
@export var brake_force : float = 1
@export var camera_turn : float = 0.2
## X axis is speed of car in km/h. Y is the engine power in that speed.
@export var power_curve : Curve
@export var power_coefficient : float = 1.0
@export var path : Path3D
@export var path_width : float = 6
#Amount of speed difference between before collision and after collision to cause engine damage in km/h.
@export var collision_speed = 20
@export var engine_pitch_curve : Curve

#Watch variables
@export var speed : float = 0.0
@export var angle_of_attack : float

@onready var camera_pivot: Marker3D = $CameraPivot
@onready var wheels : Array[VehicleWheel3D] = [$VehicleWheel3D, $VehicleWheel3D2, $VehicleWheel3D3, $VehicleWheel3D4]
@onready var grip_penalty_cooldown: Timer = $GripPenaltyCooldown
@onready var power_penalty_cooldown: Timer = $PowerPenaltyCooldown
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $EngineSound
@onready var crash: AudioStreamPlayer3D = $Crash
@onready var scratch: AudioStreamPlayer3D = $Scratch
var can_grip_penalized : bool = true
var can_power_penalized : bool = true
var last_velocity : Vector3

# Camera
var rotationSpeed: Vector2
var sensitivity = 0.08
@onready var camera: Camera3D = $CameraPivot/Camera3D

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 12
	last_velocity = linear_velocity
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	scratch.stream_paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	power_penalty()
	grip_penalty()
	
	# Camera
	camera.rotation.y -= rotationSpeed.x * delta * sensitivity
	camera.rotation.y = clampf(camera.rotation.y, -PI/1.1, PI/7)
	var verticalRotation = clampf(camera.rotation.x - (rotationSpeed.y * delta * sensitivity), -PI/6, PI/4)
	camera.rotation.x = verticalRotation
	rotationSpeed = Vector2.ZERO
	
	speed = linear_velocity.length() * 3.6
	audio_stream_player_3d.pitch_scale = move_toward(audio_stream_player_3d.pitch_scale, engine_pitch_curve.sample(speed), delta * 1.5) * (0.94 + power_coefficient * 0.06)
	steering = move_toward(steering, Input.get_axis("right", "left") * deg_to_rad(max_steer), delta * steer_speed)
	camera_pivot.rotation.y = steering / deg_to_rad(max_steer) * camera_turn
	#Speed is multiplied with 3.6 to convert it to km/h
	var front_vector := global_basis * Vector3.RIGHT
	angle_of_attack = linear_velocity.dot(front_vector)
	#Directional brake logic.
	#When opposite direction pressed it brakes instead of powering wheels.
	if angle_of_attack >= 0:
		engine_force = Input.get_action_strength("foward") * power_curve.sample(linear_velocity.length() * 3.6) * power_coefficient
		brake = Input.get_action_strength("back") * brake_force
	if angle_of_attack <= 0:
		engine_force = -Input.get_action_strength("back") * power_curve.sample(linear_velocity.length() * 3.6) * power_coefficient
		brake = Input.get_action_strength("foward") * brake_force
	if speed < 10:
		engine_force = Input.get_axis("back", "foward") * power_curve.sample(linear_velocity.length() * 3.6) * power_coefficient
		brake = 0
	if Input.get_action_strength("brake") > 0:
		brake = Input.get_action_strength("brake") * brake_force * 2

# Camera control
func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
	if (_event is InputEventMouseMotion) && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion : InputEventMouseMotion = _event
		rotationSpeed = motion.screen_relative
		
func _unhandled_input(event):
	if event is InputEventScreenDrag:
		var drag : InputEventScreenDrag = event
		rotationSpeed = drag.velocity * sensitivity

func grip_penalty():
	var closest_path_point := path.curve.get_closest_point(global_position - path.global_position) + path.global_position
	if (global_position - closest_path_point).length() > path_width && can_grip_penalized:
		for wheel in wheels:
			wheel.wheel_friction_slip *= 0.75
		can_grip_penalized = false
		grip_penalty_cooldown.start()

func power_penalty():
	var rid := get_rid()
	var state := PhysicsServer3D.body_get_direct_state(rid)
	var acceleration : float = abs(linear_velocity.length() - last_velocity.length())
	last_velocity = linear_velocity
	for i in get_contact_count():
		var collision_point := (collision_shape_3d.global_basis.inverse() * (state.get_contact_collider_position(i) - collision_shape_3d.global_position))
		if (collision_point.x > 2) && ((acceleration * 3.6) > collision_speed) && can_power_penalized:
			print("penalized")
			crash.play(3.6)
			power_coefficient *= 0.75
			can_power_penalized = false
			power_penalty_cooldown.start()
	if (acceleration * 3.6) < collision_speed && get_contact_count() > 0 && speed > 1:
		scratch.stream_paused = false
	else:
		scratch.stream_paused = true

func _on_grip_penalty_cooldown_timeout() -> void:
	can_grip_penalized = true


func _on_power_penalty_cooldown_timeout() -> void:
	can_power_penalized = true
