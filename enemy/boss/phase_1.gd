extends Phase

func start() -> void:
	while boss.health > 0:
		Danmaku.spawn_circle(14, boss.position, 7, randi(), Danmaku.TYPE_CIRCLE, Color.BLUE)
		await boss.wait(0.4)
