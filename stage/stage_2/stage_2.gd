extends Stage

func start():
	background_scene = preload("uid://d2nn2p4lcttyo")
	spellcard_background_scene = preload("uid://c066duutcevli")
	sections = [enemy_tst_1, boss_tst_1]
	
	super.start()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

#region sections

	#region enemy1
func enemy_tst_1():
	var d = 1
	for count in 2:
		for i in 4:
			var enemy = Danmaku.spawn_enemy(Vector2(-320 * d + (i * 96 * d), -300), 8)
			
			enemy.set_behavior(enemy_tst_1_move.bind(), [enemy, d])
			enemy.set_behavior(enemy_tst_1_shoot.bind(), [enemy])
			await Tool.quick_timer(0.2).timeout
		await Tool.quick_timer(2.2).timeout
		d *= -1

func enemy_tst_1_move(args: Array):
	var enemy = args[0]
	enemy.velocity = Vector2.DOWN * 10 * 60
	Tool.quick_tween(enemy, "velocity", Vector2.ZERO, 0.4, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
	await enemy.wait(1.5)
	Tool.quick_tween(enemy, "velocity", Vector2(1 * args[1] * -1, 0.5) * 10 * 60 , 1, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)

func enemy_tst_1_shoot(args: Array):
	var enemy = args[0]
	for i in 6:
		await enemy.wait(0.135)
		for count in 2:
			var bullet: = Danmaku.spawn_bullet(enemy.position, 6 + randf_range(-2, 1), 90 + randf_range(-30, 30), Danmaku.TYPE_SQUARE, Color.PURPLE)
			#bullet.add_blending = false
#endregion

	#region boss1
func boss_tst_1() -> void:
	full_clear()
	var new_boss = Danmaku.spawn_boss(preload("uid://7bs3jshyifd4"))
	boss = new_boss
	spellcard_background.boss = boss
	%GameUI.boss_added()
	
	await boss.defeated
#endregion

#endregion
