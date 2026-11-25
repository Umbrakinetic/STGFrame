extends Stage

func start():
	background_scene = preload("uid://bnvr4tc24o5q0")
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
		for i in 8:
			var enemy = Danmaku.spawn_enemy(Vector2(-320 * d, -300), 8)
			
			enemy.set_behavior(enemy_tst_1_move.bind(), [enemy, d])
			enemy.set_behavior(enemy_tst_1_shoot.bind(), [enemy])
			await Tool.quick_timer(0.2).timeout
		await Tool.quick_timer(1.8).timeout
		d *= -1
		

func enemy_tst_1_move(args: Array):
	var enemy = args[0]
	enemy.velocity = Vector2.DOWN * 10 * 60
	await enemy.wait(0.2)
	Tool.quick_tween(enemy, "velocity", Vector2.RIGHT * 10 * 60 * args[1], 1, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)

func enemy_tst_1_shoot(args: Array):
	var enemy = args[0]
	for i in 24:
		await enemy.wait(0.3)
		Danmaku.spawn_bullet(enemy.position, 8, Tool.get_angle_to_player(enemy.position))

	#endregion

	#region boss1
func boss_tst_1() -> void:
	full_clear()
	var new_boss = Danmaku.spawn_boss(preload("uid://fkamamt0yhi1"))
	boss = new_boss
	$SpellcardBackground.boss = boss
	%GameUI.boss_added()
	
	await boss.defeated
	#endregion

#endregion
