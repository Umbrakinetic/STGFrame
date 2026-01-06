extends Node2D

var c: int = 1

func _ready():
	pass
	#enemy_tst_1()
	#tst_1()
	boss_tst_1()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	%DebugBulletCount.text = str(Gametray.bullet_list.size())
	%DebugFPS.text = str(Engine.get_frames_per_second())

#region pattern1
func tst_1():
	while true:
		
		
		for count in 16:
			var s: int = Tool.rand_sign()
			var curve = randf_range(0.3, 1) * s
			var color: Color = Color.from_ok_hsl(c / 80.0, 1, 0.5, 1)
			var b: = Danmaku.spawn_circle(20, Vector2.ZERO, 5, randi(), Danmaku.TYPE_CIRCLE, color)
			for i in b:
				i.set_behavior(tst_1_custom.bind(), [i, curve])
			await Tool.quick_timer(0.12).timeout
			c += 1
		await Tool.quick_timer(3).timeout

func tst_1_custom(args: Array) -> void:
	var b: Bullet = args[0]
	var curve = args[1]
	Tool.quick_tween_method(b, b.set_speed, b.get_speed(), b.get_speed()/8, 1)
	Tool.quick_tween(b, "curve", curve)
	await b.wait(1.4)
	b.sprite.bullet_type = Danmaku.TYPE_ARROWHEAD
	Tool.quick_tween_method(b, b.set_speed, b.get_speed(), b.get_speed()*12, 3, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)
	Tool.quick_tween(b, "curve", curve / 4)
	b.set_size(Vector2.ONE * max(abs(curve * 2), 1.2))
	Tool.quick_tween_method(b, b.set_size, b.size, b.size / 2, 0.3, Tween.EASE_OUT)
	#b.sprite.passive_rotation = 2 * -sign(curve)
#endregion

#region pattern2
func tst_2() -> void:
	while true:
		var b = Danmaku.spawn_bullet(Vector2.ZERO, 3, randi(), Danmaku.TYPE_SLAVE, Color.WHITE)
		b.set_behavior(custom.bind(), [b])
		b.get_node("%Sprite").passive_rotation = 2
		await Tool.quick_timer(1).timeout

func custom(arg: Array):
	var b: Bullet = arg[0]
	b.accelerate(8, 3)
	b.curve = 0.4
	while b:
		await b.wait(0.4)
		var circ: = Danmaku.spawn_circle(8, b.position, 2, randi(), Danmaku.TYPE_ARROWHEAD)
		for i in circ:
			i.accelerate(6, 2)
	
#endregion

#region pattern3
func tst_3() -> void:
	await Tool.quick_timer(1).timeout
	var slave = Danmaku.spawn_slave()
	slave.scale = Vector2.ZERO
	var tween: = Tool.quick_tween(slave, "scale", Vector2.ONE)
	slave.lifetime_frames = -1
	
	await tween.finished
	var tween2: = Tool.quick_tween(slave, "scale", Vector2(8, 1), 0.7)
	Tool.quick_tween(slave, "position:y", -196, 0.7)
	
	await tween2.finished
	while slave:
		var p = Vector2(randf_range(-384, 384), randf_range(-128, -200))
		var to_player = rad_to_deg(p.angle_to_point(get_node("Player").global_position))
		for count in 1:
			Danmaku.spawn_bullet(p, randf_range(8, 12), 90, Danmaku.TYPE_CRYSTAL, Color.BLUE)
		await Tool.quick_timer(0.02).timeout
#endregion

#region enemy1
func enemy_tst_1():
	var scene = preload("uid://etx7et4252gc")
	var d = 1
	while true:
		for i in 8:
			var enemy = scene.instantiate()
			Gametray.add_child(enemy)
			enemy.global_position = Vector2(-320 * d, -300)
			enemy.health = 60
			enemy.set_behavior(enemy_tst_1_move.bind(), [enemy, d])
			enemy.set_behavior(enemy_tst_1_shoot.bind(), [enemy])
			await Tool.quick_timer(0.4).timeout
		await Tool.quick_timer(1.8).timeout
		d *= -1
		

func enemy_tst_1_move(args: Array):
	var enemy = args[0]
	enemy.velocity = Vector2.DOWN * 4 * 60
	await enemy.wait(1)
	Tool.quick_tween(enemy, "velocity", Vector2.RIGHT * 4 * 60 * args[1], 1, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)
	#await enemy.wait(4)
	#enemy.queue_free()

func enemy_tst_1_shoot(args: Array):
	var enemy = args[0]
	for i in 24:
		await enemy.wait(0.2)
		Danmaku.spawn_bullet(enemy.position, 8, Tool.find_angle_to_player(enemy.position))

#endregion

#region boss1
func boss_tst_1() -> void:
	var boss = preload("uid://du3vcvy2rhe0m").instantiate()
	Gametray.add_child(boss)
	boss.global_position = Vector2(0, -320)
	Tool.boss = boss
	$GameUI.boss_present = true
	$GameUI.boss_added()
#endregion
