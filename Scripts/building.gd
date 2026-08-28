extends Node3D

@onready var colors : Array = [Color(0.841, 0.833, 0.739, 1.0), 
Color(0.527, 0.656, 0.497, 1.0), Color(1.0, 0.4, 0.28, 1.0)]

func _ready():
	var mesh: MeshInstance3D = get_child(0)
	
	# Choose random color
	var color = colors[randi_range(0, colors.size()-1)]
	
	# Modifying an override material
	if mesh.material_override:
		mesh.material_override.albedo_color = color
	# Modifying the active surface material
	else:
		var mat = mesh.get_active_material(0).duplicate()
		mat.albedo_color = color
		mesh.set_surface_override_material(0, mat)
