extends Phase

func start() -> void:
	boss.invincible = true
	var move_tween = Tool.quick_tween(boss, "global_position", Vector2.ZERO, 1, Tween.EASE_IN, Tween.TRANS_LINEAR)
	await move_tween.finished
	
	boss.declare_spell("Development Sign \"Test Pattern\"")
	loop()
	
	await Tool.quick_timer(2).timeout
	boss.invincible = false

func loop() -> void:
	var count: float = 0
	var mult: float = 3
	while boss.health > 0:
		var pos = boss.global_position + Vector2(240 * cos(count / 60), 120 * sin(count / 60))
		var npos = boss.global_position - Vector2(240 * cos(count / 60), 120 * sin(count / 60))
		for speed in range(4, 7):
			var bullet: = Danmaku.spawn_bullet(pos, speed, 0, Danmaku.TYPE_RICE, Color.RED)
			var bullet2: = Danmaku.spawn_bullet(npos, speed, 0, Danmaku.TYPE_RICE, Color.BLUE)
			
			for i in [bullet, bullet2]:
				i.set_angle(rad_to_deg(i.global_position.angle_to_point(boss.global_position)) + 180)
		
		count += mult
		await boss.wait(mult / 60.0)
