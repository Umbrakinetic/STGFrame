extends Phase

func start() -> void:
	boss.invincible = true
	loop()
	
	await Tool.quick_timer(2).timeout
	boss.invincible = false

func loop() -> void:
	while boss.health > 0:
		var c: = Danmaku.spawn_circle(18, boss.position, 4, randi(), Danmaku.TYPE_CIRCLE, Color.RED)
		for b in c:
			b.accelerate(12, 3)
		await boss.wait(0.5)
