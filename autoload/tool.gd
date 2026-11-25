## Class that holds a bunch of nice general-use functions.
class_name Tool
extends Node

## The leftmost edge of the default playfield.
const PLAYFIELD_LEFT   : int = -382
## The rightmost edge of the default playfield.
const PLAYFIELD_RIGHT  : int = 382
## The topmost edge of the default playfield.
const PLAYFIELD_TOP    : int = -240
## The bottommost edge of the default playfield.
const PLAYFIELD_BOTTOM : int = 656

## In degrees, gets the angle of the player from the given Vector2.[br]
## If player is absent, returns 90 as a failsafe.
static func get_angle_to_player(from: Vector2) -> float:
	if Stage.player != null:
		return rad_to_deg(from.angle_to_point(Stage.player.global_position))
	return 90

## Gets the squared distance to the player from the given Vector2.[br]
## If player is absent, returns 0 as a failsafe.
static func get_distance_to_player(from: Vector2) -> float:
	if Stage.player != null:
		return from.distance_squared_to(Stage.player.global_position)
	return 0

## returns -1 or 1 at random.
static func rand_sign() -> int:
	return [1,-1].pick_random()

## Returns a Vector2 whose x and y values are randomly someplace in the given values.
## y value is optional; if no argument is provided, y value will use the x value.
## For example, 
## rand_vector2(24, 48) will return a Vector2 whose x value is somewhere between -24, 24
## and whose y value is somewhere between -48, 48.
## rand_vector2(72) will return a Vector2 whose x and y values are somewhere between -72, 72.
static func rand_vector2(value_x: float, value_y: float = -1) -> Vector2:
	if value_y == -1: value_y = value_x
	return Vector2(
		randf_range(-value_x, value_x),
		randf_range(-value_y, value_y)
	)

## Functions similarly to rand_vector2(), but polls for points with a minimum 
## distance from the player.
## Useful for spawning bullets randomly without allowing them to spawn inside the player.
static func rand_vector2_distance_from_player(distance_squared: float = 8192) -> Vector2:
	for i in 10:
		var point = Vector2(
			randf_range(-384, 384),
			randf_range(-240, 656)
		)
		if point.distance_squared_to(Stage.player.global_position) >= distance_squared:
			return point
	
	return Vector2.ZERO

## Physics formula for speed.
static func p_speed(v_distance: float, v_time: float) -> float:
	return (v_distance / v_time) / 60
## Physics formula for distance.
static func p_distance(v_speed: float, v_time: float) -> float:
	return (v_speed * 60) * v_time
## Physics formula for time.
static func p_time(v_distance: float, v_speed: float) -> float:
	return v_distance / (v_speed * 60)

## Returns an array of all nodes parented under a specified node,
## including grandchildren, grand-grandchildren, etc.[br]
## Can optionally be filtered by class.
static func get_all_children(node: Node, of_type: Variant = null) -> Array:
	var array: Array = []
	for child: Node in node.get_children():
		if of_type == null or is_instance_of(child, of_type):
			array.append(child)
		array.append_array(get_all_children(child, of_type))
	return array

## Condenses a common Tween workflow into one function.
static func quick_tween(object: Variant, property: NodePath, final_value: Variant, duration: float = 1, tween_ease: Tween.EaseType = Tween.EASE_IN_OUT, tween_trans: Tween.TransitionType = Tween.TRANS_CIRC) -> Tween:
	var tween: Tween = object.create_tween()
	tween.set_ease(tween_ease)
	tween.set_trans(tween_trans)
	tween.tween_property(object, property, final_value, duration)
	return tween

## Functions similarly to quick_tween(), but works for tween_method() instead of tween_property().
static func quick_tween_method(object: Variant, method: Callable, from: Variant, final_value: Variant, duration: float = 1, tween_ease: Tween.EaseType = Tween.EASE_IN_OUT, tween_trans: Tween.TransitionType = Tween.TRANS_CIRC) -> Tween:
	var tween: Tween = object.create_tween()
	tween.set_ease(tween_ease)
	tween.set_trans(tween_trans)
	tween.tween_method(method, from, final_value, duration)
	return tween

## Sets up a timer configured for use in gameplay.
## Example usage:[br]
## await Tool.quick_timer(1).timeout[br]
## Waits for one second.[br]
static func quick_timer(duration_sec: float) -> SceneTreeTimer:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		var timer = tree.create_timer(duration_sec, false, true)
		return timer
	return null

## Sorts an array of Node2Ds by distance to reference_point.
static func sort_closest(array: Array, reference_point: Vector2) -> Array:
	array.sort_custom(func(a, b):
		return a.global_position.distance_squared_to(reference_point) < b.global_position.distance_squared_to(reference_point))
	
	return array

## Calculates a sinewave that peaks at every c interval.
static func peak_sine(x: float, c: float) -> float:
	return cos(TAU * x / c)

## Calculates a triangle wave (zigzag) that peaks at every c interval.
static func peak_triangle(x: float, c: float) -> float:
	var t := x / c
	return 1.0 - 4.0 * absf(t - roundf(t))

## Creates an AudioStreamPlayer2D that plays one sound, then frees itself.
static func oneshot_sound(sound: AudioStream, pitch: float = 1, volume: float = 1):
	var player = AudioStreamPlayer2D.new()
	Gametray.add_child(player)
	player.stream = sound
	player.pitch_scale = pitch
	player.volume_linear = volume
	player.play()
	await player.finished
	player.queue_free()


## Creates a Sprite2D that displays an animation using the hframes and vframes properties.[br]
## When the animation is finished, the Sprite2D frees itself.
static func oneshot_sprite(sprite: Texture2D, hframes: int, vframes: int, anim_time_sec: float, pos: Vector2):
	pass
