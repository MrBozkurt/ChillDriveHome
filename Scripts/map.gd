extends Node3D

@onready var path_follow_3d: PathFollow3D = $Path3D/PathFollow3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	path_follow_3d.progress_ratio += delta * delta
	pass
