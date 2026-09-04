extends Area2D

var player

var expanding: bool = true

func _physics_process(delta: float) -> void:
	for i in get_overlapping_areas():
		var parent = i.get_parent()
		if parent is Enemy:
			parent.take_damage(3)

func _ready() -> void:
	player._set_invincibility(3)
	#$Line2D.material = $Line2D.material.duplicate()
	
	afterimage_loop()
	
	scale = Vector2.ZERO
	var twn = Tool.quick_tween(self, "scale", Vector2.ONE * 3, 1.5, Tween.EASE_OUT)
	twn.parallel().tween_property(self, "rotation_degrees", 540 * Tool.rand_sign(), 1.5)
	
	twn.set_trans(Tween.TRANS_LINEAR)
	twn.parallel().tween_property(self, "modulate:a", 0, 1)
	
	await twn.step_finished
	expanding = false
	
	await twn.finished
	player.bombing = false
	queue_free()

func afterimage_loop() -> void:
	while true:
		await Tool.quick_timer(0.03).timeout
		var line: Line2D = $Line2D.duplicate()
		Gametray.add_child(line)
		line.material = null
		line.modulate.a = 0.2
		line.global_transform = global_transform
		fade(line)

func fade(line: Line2D) -> void:
	var after_tween: = Tool.quick_tween(line, "modulate:a", 0, 0.75)
	after_tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	after_tween.parallel().tween_property(line, "scale", line.scale * 1.5, 0.75)
	after_tween.finished.connect(func(): line.queue_free())

func _on_body_entered(body: Node2D) -> void:
	if body is Bullet and not body.is_in_group("playerbullet") and body.cancellable:
		body.start_free()
