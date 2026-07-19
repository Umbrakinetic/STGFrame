class_name Trail extends Line2D

var max_points: int = 20
var point_array: Array[Vector2] = []

## The Node2D this trail is following
var tracking: Node2D

var update_frame: int = 1

func set_length(value: int = 20):
	max_points = value
func set_start_width(value: float = 1):
	width_curve.set_point_value(0, value)
func set_end_width(value: float = 0):
	width_curve.set_point_value(1, value)
func set_start_color(value: Color = Color.WHITE):
	gradient.set_color(0, value)
func set_end_color(value: Color = Color.WHITE):
	gradient.set_color(1, value)

func _ready() -> void:
	var pos = tracking.global_position
	clear_points()
	
	if tracking == Bullet: tracking.started_freeing.connect(start_remove.bind())
	else: tracking.tree_exiting.connect(start_remove.bind())

func start_remove():
	var tween: = Tool.quick_tween(self, "modulate:a", 0, 0.1, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)
	await tween.finished
	queue_free()

var count: int = update_frame
func _process(delta: float) -> void:
	if tracking == null: 
		#queue_free()
		return
	
	count += 1
	if count % update_frame == 0:
		
		var pos = tracking.global_position
		
		point_array.push_front(pos)
		
		if point_array.size() > max_points:
			point_array.pop_back()
		
		clear_points()
		
		for point in point_array:
			add_point(point)
