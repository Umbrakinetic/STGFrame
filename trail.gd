extends Line2D

var max_points: int = 20
var point_array: Array[Vector2] = []

## The Node2D this trail is following
var tracking: Node2D

var last_pos: Vector2

func _process(delta: float) -> void:
	if tracking == null: 
		queue_free()
		return
	
	var pos = tracking.global_position
	
	point_array.push_front(pos)
	
	if point_array.size() > max_points:
		point_array.pop_back()
	
	clear_points()
	
	for point in point_array:
		add_point(point)
