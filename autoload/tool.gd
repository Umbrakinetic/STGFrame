extends Node

@onready var player = get_tree().current_scene.get_node("Player")

var boss: Enemy

func find_angle_to_player(from: Vector2) -> float:
	return rad_to_deg(from.angle_to_point(get_tree().current_scene.get_node("Player").global_position))

func rand_sign() -> int:
	return [1,-1].pick_random()

func rand_vector2(value_x: float, value_y: float = -1) -> Vector2:
	if value_y == -1: value_y = value_x
	return Vector2(
		randf_range(-value_x, value_x),
		randf_range(-value_y, value_y)
	)
func speed(v_distance: float, v_time: float) -> float:
	return (v_distance / v_time) / 60
func distance(v_speed: float, v_time: float) -> float:
	return (v_speed * 60) * v_time
func time(v_distance: float, v_speed: float) -> float:
	return v_distance / (v_speed * 60)

func get_all_children(node: Node) -> Array:
	var array: Array = []
	if node.get_child_count() == 0: return array
	for child in node.get_children():
		array.append(child)
		array.append_array(get_all_children(child))
	return array

func quick_tween(object: Variant, property: NodePath, final_value: Variant, duration: float = 1, tween_ease: Tween.EaseType = Tween.EASE_IN_OUT, tween_trans: Tween.TransitionType = Tween.TRANS_CIRC) -> Tween:
	var tween: Tween = object.create_tween()
	tween.set_ease(tween_ease)
	tween.set_trans(tween_trans)
	tween.tween_property(object, property, final_value, duration)
	return tween

func quick_tween_method(object: Variant, method: Callable, from: Variant, final_value: Variant, duration: float = 1, tween_ease: Tween.EaseType = Tween.EASE_IN_OUT, tween_trans: Tween.TransitionType = Tween.TRANS_CIRC) -> Tween:
	var tween: Tween = object.create_tween()
	tween.set_ease(tween_ease)
	tween.set_trans(tween_trans)
	tween.tween_method(method, from, final_value, duration)
	return tween

func quick_timer(duration: float) -> SceneTreeTimer:
	if get_tree():
		var timer = get_tree().create_timer(duration, false, true)
		return timer
	return null

func sort_closest(array: Array, reference_point: Vector2) -> Node2D:
	array.sort_custom(func(a, b):
		return a.global_position.distance_squared_to(reference_point) < b.global_position.distance_squared_to(reference_point))
	
	return array[0]
