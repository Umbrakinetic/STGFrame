extends Area2D

var player: Player

var expanding: bool = true

func _physics_process(delta: float) -> void:
	global_position = player.global_position
	
	if Input.is_action_pressed("ui_left"):
		global_rotation_degrees = clamp(global_rotation_degrees - 0.1, -105, -75)
	if Input.is_action_pressed("ui_right"):
		global_rotation_degrees = clamp(global_rotation_degrees + 0.1, -105, -75)
	
	for i in get_overlapping_areas():
		var parent = i.get_parent()
		if parent is Enemy:
			parent.take_damage(2)

func _ready() -> void:
	player._set_invincibility(4)
	player.speed = 100
	
	scale.y = 0
	var twn = Tool.quick_tween(self, "scale:y", 1, 1, Tween.EASE_OUT)
	twn.tween_interval(2.5)
	twn.tween_property(self, "modulate:a", 0, 0.5)
	
	await twn.finished
	player.bombing = false
	player.speed = player.default_speed
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Bullet and not body.is_in_group("playerbullet") and body.cancellable:
		body.start_free()
