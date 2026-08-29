extends Node3D

@onready var colors : Array = [Color(0.981, 0.98, 0.967, 1.0), 
Color(0.044, 0.053, 0.084, 1.0), Color(0.73, 0.0, 0.0, 1.0),
Color(0.226, 0.424, 0.413, 1.0), Color(0.463, 0.463, 0.463, 1.0),
Color(0.112, 0.145, 0.51, 1.0)]

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
