class_name Bullet extends CharacterBody2D

signal finished_spawning

signal acceleration_finished

var parented: bool = false

var accelerating: bool = false

var animated: bool = false

## How fast the bullet is moving.
@export var speed: float = 1
func get_speed():
	return velocity.length() / 60
func set_speed(value):
	speed = value
	update_velocity(speed, angle)

## In degrees, which direction the bullet is facing.
@export var angle: float = 0
func get_angle():
	if velocity.is_zero_approx():
		return angle
	else:
		return rad_to_deg(velocity.angle())
func set_angle(value) -> void:
	angle = value
	rotation_degrees = value
	update_velocity(speed, angle)

## in degrees, how much a bullet's angle changes per frame.
@export var curve: float = 0 

## The bullet's size.
@export var size: Vector2 = Vector2(1, 1)
func set_size(value) -> void:
	size = value
	scale = value

## The bullet's transparency.
@export var alpha: float = 255
func set_alpha(value) -> void:
	alpha = value
	modulate.a = alpha
func get_alpha() -> float:
	return modulate.a

## In seconds, how long the bullet delays before firing.
## The bullet cannot be cancelled and it cannot hit the player during this time.
@export var delay: float = 0.2

## In frames, how long the bullet persists in-game before disappearing. Set to -1 to let it persist indefinitely (do so with caution).
@export var lifetime_frames: int = 720

## if a bullet is able to be deleted by most usual bullet clearing methods, such as special attacks or hitting an obstacle, it is considered cancellable. 
## A bullet should not be cancellable if it has significant importance to a pattern such that a pattern would break in an irrecoverable way without it.
## This can also be used if you just want to be mean to the player and don't want them to cancel bullets for whatever reason.
@export var cancellable: bool = true

var spawning: bool = true

## is the current bullet in the start_free() process?
var freeing: bool = false

#var origin: Enemy

## variable used to force a bullet to move to a certain position.
var force_moving: bool = false
var force_position: Vector2 = Vector2(0, 0)

var accel_tween: Tween

## the point of collision between a bullet and a colliding object.
var collision_point: Vector2

@onready var sprite: Node2D = %Sprite
@onready var hitbox: CollisionShape2D = %Hitbox

func _ready() -> void:
	rotation_degrees = get_angle()
	if delay > 0:
		set_size(size * 2)
		var spawn_modulate = modulate.a
		modulate.a = 0
		var tween: = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_STOP)
		tween.tween_property(self, "modulate:a", spawn_modulate, delay)
		tween.parallel().tween_method(set_size, size, size / 2, delay)
		disable_hitbox()
		
		await tween.finished
		enable_hitbox()
	spawning = false
	emit_signal("finished_spawning")

func _physics_process(delta: float) -> void:
	# Automatically handles the rotation.
	global_rotation = velocity.angle()
	
	# Curves the bullet's trajectory.
	if curve != 0:
		set_angle(get_angle() + curve)
	
	# Ticks down the bullet's lifetime, freeing the bullet at 0.
	if lifetime_frames > 0: 
		lifetime_frames -= 1
		if lifetime_frames == 0 and not freeing: start_free()
	
	if not spawning:
		var collision: = move_and_collide((velocity / 60.0) * Engine.time_scale)

# Function to salvage everything that is not directly related to the bullet.
# the bullet's components, like its sprite, are freed. Children bullets are reparented to the Gametray.
func start_free(delete_type: Variant = 1, predelay: float = 0.0) -> void:
	kill_acceleration()
	set_speed(get_speed() / 10)
	freeing = true
	disable_hitbox()
	
	if predelay != 0: await Tool.quick_timer(predelay).timeout
	
	var delete_time: float = 0.2
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	match delete_type: 
		Danmaku.DELETE_INSTANT:
			queue_free()
			return
		Danmaku.DELETE_FADEGROW:
			tween.tween_method(set_size, size, size * 2, delete_time)
			tween.parallel().tween_method(set_alpha, get_alpha(), 0, delete_time)
		Danmaku.DELETE_FADE:
			tween.tween_method(set_alpha, get_alpha(), 0, delete_time)
	await tween.finished
	queue_free()


# Updates the linear velocity to match the current speed & angle.
func update_velocity (current_speed: float, current_angle: float) -> void:
	var radian: float = deg_to_rad(current_angle)
	velocity = Vector2(cos(radian), sin(radian)) * (current_speed * 60.0)

# self-explanatory.
func is_danmaku(input) -> bool:
	return input is Bullet or input is GPUParticles2D#TODO: or laser or obstacle


# Simple function that waits for a certain amount of frames.
func frame_timer(frames: int) -> void:
	for i in frames:
		if is_inside_tree():
			await get_tree().physics_frame

# Self-explanatory.
#func find_angle_to_player(pos: Vector2 = self.global_position) -> float:
	#return rad_to_deg(pos.angle_to_point(Global.player.global_position))

#func find_angle_to_closest_enemy(pos: Vector2 = self.global_position) -> float:
	#var enemy_array = get_tree().current_scene.get_node("%GameTray").get_children().filter(is_enemy)
	#if enemy_array.size() > 0:
		#enemy_array.sort_custom(sort_closest)
		#return rad_to_deg(pos.angle_to_point(enemy_array.front().global_position))
	#return get_angle()

#func is_enemy(input: Node) -> bool:
	#return input is Enemy

func sort_closest(a, b) -> Variant:
	return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position)

## Accelerates a bullet to a given speed over time.
## If accelerate is called again while already accelerating, the current acceleration is overridden.
func accelerate(final_speed: float, time: float) -> void:
	if accel_tween != null: accel_tween.kill()
	accelerating = true
	accel_tween = create_tween()
	accel_tween.tween_method(set_speed, get_speed(), final_speed, time)
	await accel_tween.finished
	accelerating = false
	emit_signal("acceleration_finished")

func kill_acceleration() -> void:
	if accel_tween != null: accel_tween.kill()
	accelerating = false

func change_angle(new_angle: float, time_sec: float, tween_ease: Tween.EaseType = Tween.EASE_OUT, trans_type: Tween.TransitionType = Tween.TRANS_CIRC) -> void:
	var tween = create_tween().set_ease(tween_ease).set_trans(trans_type)
	tween.tween_method(set_angle, get_angle(), new_angle, time_sec)

func disable_hitbox() -> void:
	$Hitbox.set_deferred("disabled", true)

func enable_hitbox() -> void:
	#if sprite.bullet_type != Danmaku.TYPE_SLAVE:
	$Hitbox.set_deferred("disabled", false)

func is_hitbox_disabled() -> bool:
	return $Hitbox.disabled

func wait(time_sec) -> void:
	if not is_inside_tree(): await tree_entered
	await get_tree().create_timer(time_sec, false, true).timeout

func set_behavior(behavior:Callable, args: Array) -> void:
	behavior.call(args)
