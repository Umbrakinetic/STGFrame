extends Phase

func start() -> void:
	boss.invincible = true
	loop()
	
	await Tool.quick_timer(2).timeout
	boss.invincible = false

func loop():
	var curve_direction = Tool.rand_sign()
	while boss.health > 0:
		var c := Danmaku.spawn_circle(16, boss.position, 6, randi(), Danmaku.TYPE_CIRCLE, Color.BLUE)
		for i in c:
			var trail = preload("uid://f1bk6nbqr6nd").instantiate()
			Gametray.add_child(trail)
			trail.tracking = i
			i.curve = 0.4 * curve_direction
		curve_direction *= -1
		await boss.wait(0.3)
