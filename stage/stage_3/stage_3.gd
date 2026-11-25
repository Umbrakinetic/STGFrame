extends Stage

func start():
	background_scene = preload("uid://c7qf2rpsjgnvy")
	spellcard_background_scene = preload("uid://c066duutcevli")
	sections = [enemy_tst_1, midboss_tst_1, enemy_tst_2, boss_tst_1]
	
	super.start()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

#region sections

	#region enemy1
func enemy_tst_1():
	var d = 1
	var offset: float = 0
	for count in 2:
		for i in 5:
			var enemy: Enemy = Danmaku.spawn_enemy(Vector2((-320 - offset) * d + (i * 144 * d), -300), 15)
			
			enemy.set_behavior(enemy_tst_1_move.bind(), [enemy, d])
			enemy.set_behavior(enemy_tst_1_shoot.bind(), [enemy])
			await Tool.quick_timer(0.5).timeout
		await Tool.quick_timer(2.2).timeout
		offset = 36
		d *= -1

func enemy_tst_1_move(args: Array):
	var enemy = args[0]
	enemy.velocity = Vector2.DOWN * 4 * 60

func enemy_tst_1_shoot(args: Array):
	var enemy = args[0]
	await enemy.wait(0.75)
	for i in 3:
		for count in 1:
			var bullet: = Danmaku.spawn_circle(6 ,enemy.position, 6, 90 + randi(), Danmaku.TYPE_ICE, Color.SKY_BLUE)
		await enemy.wait(0.6)
#endregion

	#region enemy2
func enemy_tst_2():
	var enemy1: = Danmaku.spawn_enemy(Vector2(0,-300), 512)
	enemy1.set_behavior(enemy_tst_2_move, [enemy1])
	await Tool.quick_timer(0.5).timeout
	for i in 24:
		var enemy2: = Danmaku.spawn_enemy(Vector2(randf_range(-384, 384), -300), 12)
		enemy2.velocity = Vector2.DOWN * 6 * 60
		enemy2.died.connect(on_enemy_death.bind(enemy2))
		await Tool.quick_timer(0.4).timeout
	await Tool.quick_timer(4).timeout

func on_enemy_death(enemy: Enemy):
	for i in 3:
		Danmaku.spawn_bullet(enemy.global_position, 5 + i, Tool.get_angle_to_player(enemy.global_position), Danmaku.TYPE_SCALE, Color.ORANGE)

func enemy_tst_2_move(args: Array):
	var enemy: Enemy = args[0]
	enemy.velocity = Vector2.DOWN * 10 * 60
	var move_tween = Tool.quick_tween(enemy, "velocity", Vector2.ZERO, 0.8)
	await move_tween.finished
	
	for i in 8:
		Danmaku.spawn_circle(32, enemy.global_position, 5.5, randi())
		await enemy.wait(1.5)
	
	Tool.quick_tween(enemy, "velocity", Vector2.UP * 10 * 60, 2)


#endregion

	#region boss1
func midboss_tst_1() -> void:
	full_clear()
	var new_boss = Danmaku.spawn_boss(preload("uid://de25imp5lk3s1"))
	boss = new_boss
	spellcard_background.boss = boss
	%GameUI.boss_added()
	await boss.defeated
	await Tool.quick_timer(1).timeout

func boss_tst_1() -> void:
	full_clear()
	var new_boss = Danmaku.spawn_boss(preload("uid://dghduhksaurek"))
	boss = new_boss
	spellcard_background.boss = boss
	%GameUI.boss_added()
	
	await boss.defeated
#	endregion

#endregion

#endregion
