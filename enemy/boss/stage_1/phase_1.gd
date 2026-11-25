extends Phase

func _init():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	phase_time = 18
	phase_health = 500
	give_drops = false

func start() -> void:
	boss.invincible = true
	
	var move_tween = Tool.quick_tween(boss, "global_position", Vector2.ZERO, 1, Tween.EASE_IN, Tween.TRANS_LINEAR)
	await move_tween.finished
	await boss.wait(1)
	
	loop()
	#loop2()
	
	await Tool.quick_timer(2).timeout
	boss.invincible = false

func loop():
	var hue = 0
	var curve_direction = Tool.rand_sign()
	var attack_count: int = 0
	while boss.health > 0:
		for count in 2:
			var c := Danmaku.spawn_circle(16, boss.position, 6 - count, randi(), Danmaku.TYPE_CIRCLEBORDER)
			for i in c:
				#i.set_passive_rotation(1)
				i.set_size(Vector2.ONE + (Vector2.ONE * (count + 0.5)))
				i.curve = 0.4 * curve_direction
				i.get_node("Sprite").color = Color.from_ok_hsl(hue, 1, 0.5)
				hue += 1.0/c.size()
			
			attack_count += 1
		curve_direction *= -1
		if attack_count % 4 == 0: Tool.quick_tween(boss, "global_position", Tool.rand_vector2(160, 100), 1, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
		await boss.wait(1)

func loop2():
	var dist = 64
	var count: float = 0
	while boss.health > 0:
		var pos = Vector2(dist * cos(count), dist * sin(count))
		var final_pos = boss.global_position + pos
		var a = rad_to_deg(final_pos.angle_to_point(boss.global_position)) + 180
		var l = Danmaku.spawn_laser(final_pos, a, 256, 1, 1, 0.4)
		Tool.quick_tween(l, "rotation_degrees", l.rotation_degrees + 8, 0.75, Tween.EASE_OUT)
		#move(l)
		l.color = Color.from_ok_hsl(randf(), 1.0, 0.5)
		var c = Danmaku.spawn_circle(4, boss.global_position, 4, randi(), Danmaku.TYPE_ARROWHEAD)
		for i in c:
			i.set_color(Color.from_ok_hsl(randf(), 1.0, 0.5))
		count += deg_to_rad(6)
		await Tool.quick_timer(0.05).timeout
