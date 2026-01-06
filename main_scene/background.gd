extends Node3D

func _process(delta: float) -> void:
	$MeshInstance3D.get_surface_override_material(0).uv1_offset.y -= 0.1 * delta
