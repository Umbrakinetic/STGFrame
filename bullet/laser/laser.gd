class_name Laser extends Area2D

@onready var beam: Array[Sprite2D] = [$BeamBottom, $BeamTop]
@onready var source: Array[Sprite2D] = [$SourceBottom, $SourceTop]

@onready var collision: CollisionShape2D = $CollisionShape2D

var length: float = 256:
	set(value):
		length = value
		for i in beam:
			i.scale.x = length
		
		collision.shape.size.x = length * 64
		collision.position.x = (length * 64) / 2

var width: float = 1:
	set(value):
		width = value
		collision.shape.size.y = 12 * width

var color: Color = Color.RED:
	set(value):
		color = value
		for i in [source[0], beam[0]]:
			i.modulate = color

var lifetime_frames: int = 60

var delay_frames: int = 90

var tween: Tween

var delay_state: bool = true

var spawn_time_sec: float = 0.35
var free_time_sec: float = 0.35

var is_freeing: bool = false

var end_point: Vector2 = Vector2.ZERO

func _ready() -> void:
	for i in beam:
		i.scale.y = 0
	for i in source:
		i.scale = Vector2.ZERO
		
	await Tool.quick_timer(delay_frames / 60.0).timeout
	
	if is_freeing:
		return
	
	collision.disabled = false
	delay_state = false
	
	for i in beam:
		Tool.quick_tween(i, "scale:y", width, spawn_time_sec, Tween.EASE_OUT)
	for i in source:
		Tool.quick_tween(i, "scale", Vector2.ONE * width, spawn_time_sec, Tween.EASE_OUT)

func _physics_process(delta: float) -> void:
	queue_redraw()
	
	end_point = to_global(global_position + global_position + Vector2(length * 64,0))
	if not delay_state and lifetime_frames > 0:
		lifetime_frames -= 1
		if lifetime_frames == 0:
			start_free()

func _draw() -> void:
	if delay_state:
		draw_line(Vector2.ZERO, global_position + Vector2(length * 64,0), Color.WHITE, 1, true)

func start_free() -> void:
	if is_freeing: return
	is_freeing = true
	collision.set_deferred("disabled", true)
	for i in beam:
		Tool.quick_tween(i, "scale:y", 0, free_time_sec, Tween.EASE_IN)
		Tool.quick_tween(i, "modulate:a", 0, free_time_sec, Tween.EASE_IN)
	for i in source:
		Tool.quick_tween(i, "scale", Vector2.ZERO, free_time_sec, Tween.EASE_IN)
		Tool.quick_tween(i, "modulate:a", 0, free_time_sec, Tween.EASE_IN)
	
	await Tool.quick_timer(free_time_sec).timeout
	queue_free()
