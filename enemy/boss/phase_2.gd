extends Phase

func start() -> void:
	boss.invincible = true
	loop()
	
	await Tool.quick_timer(2).timeout
	boss.invincible = false

func loop() -> void:
	while boss.health > 0:
		var c: = Danmaku.spawn_circle(12, boss.position, 6, randi(), Danmaku.TYPE_CIRCLE, Color.RED)
		for b in c:
			b.set_behavior(spin.bind(), [b])
		await boss.wait(0.5)


func spin(args: Array):
	var b: Bullet = args[0]
	await b.wait(1)
	b.set_speed(0)
	b.accelerate(6, 1)
	Danmaku.spawn_bullet(b.global_position, 6, b.get_angle(), Danmaku.TYPE_CIRCLE, Color.YELLOW)
	b.set_angle(b.get_angle() + 90)
	
	
	await b.wait(1)
	b.set_speed(0)
	b.accelerate(6, 1)
	Danmaku.spawn_bullet(b.global_position, 6, b.get_angle(), Danmaku.TYPE_CIRCLE, Color.GREEN)
	b.set_angle(b.get_angle() -135)
	
