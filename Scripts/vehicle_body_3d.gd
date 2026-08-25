extends VehicleBody3D

@export var MAX_STEER : float = 0.4
@export var ENGINE_POWER : float = 100
@export var BRAKE_FORCE : float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("right", "left") * MAX_STEER, delta * 1.0)
	engine_force = Input.get_axis("back", "foward") * ENGINE_POWER
	brake = Input.get_action_strength("brake") * BRAKE_FORCE
