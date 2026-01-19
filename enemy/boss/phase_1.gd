extends Phase

func start() -> void:
	boss.invincible = true
	loop()
	
	await Tool.quick_timer(2).timeout
	boss.invincible = false
	

#func loop():
	#var s: = 0.0
	#while boss.health > 0:
		#s += 0.25
		#var a := Danmaku.spawn_arc(3, boss.position, 6, 90 + (45 * sin(s)), Danmaku.TYPE_SCALE, Color.YELLOW, boss, 45)
		#for b in a:
			#b.get_node("%Sprite").material = null
		#await boss.wait(0.05)

#func loop():
	#while boss.health > 0:
		#var c := Danmaku.spawn_circle(6, boss.position, 5, randi(), Danmaku.TYPE_SCALE, Color.BLUE)
		#for i in c:
			#i.set_behavior(fall.bind(), [i])
		#await boss.wait(0.9)

func loop():
	while boss.health > 0:
		for i in 4:
			Danmaku.spawn_bullet(boss.position, randf_range(4, 7), randi())
		await boss.wait(0.05)

func fall(args: Array):
	var b = args[0]
	
	while b != null:
		if b.global_position.y >= 656:
			Danmaku.spawn_circle(6, b.global_position, 5, randi(), Danmaku.TYPE_BLADE, Color.SKY_BLUE)
			b.queue_free()
		b.velocity.y += 9.8 * 0.5
		await get_tree().physics_frame
