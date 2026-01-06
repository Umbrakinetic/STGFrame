extends Area2D

func _on_body_exited(body: Node2D) -> void:
	if body is Bullet:
		body.start_free()

func _on_area_entered(area: Area2D) -> void:
	var e = area.get_parent()
	if e is Enemy:
		e.queue_free()
