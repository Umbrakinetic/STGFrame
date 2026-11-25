extends Phase

var circle_count = 18
var circle_radius = 128
var circle_angle = randi()

func start() -> void:
	boss.invincible = true
	var move_tween = Tool.quick_tween(boss, "global_position", Vector2.ZERO, 1, Tween.EASE_IN, Tween.TRANS_LINEAR)
	await move_tween.finished
	
	boss.declare_spell("Development Sign \"Test Pattern\"")
	loop()
	
	await Tool.quick_timer(2).timeout
	boss.invincible = false

func loop() -> void:
	while boss.health > 0:
		circle_angle = randi()
		scatter_circle()
		await boss.wait(2)


func scatter_circle():
	var circle_center_pos = Vector2(randf_range(-324, 324), randf_range(-150, -50))
	for i in circle_count:
		var pos = Tool.rand_vector2_distance_from_player(8192)
		
		var angle = (360.0 / circle_count) * i
		
		var bullet:  = Danmaku.spawn_bullet(pos, 0, 0, Danmaku.TYPE_CIRCLE, Color.BLUE)
		bullet.set_behavior(assemble_circle, [bullet, circle_center_pos, i, circle_radius, angle])

func assemble_circle(args: Array = []):
	var bullet: Bullet = args[0]
	var circle_center_pos: Vector2 = args[1]
	var index: int = args[2]
	var radius: float = args[3]
	var angle: float = args[4]
	
	var rad = deg_to_rad((angle))
	
	var final_pos = circle_center_pos + (Vector2(cos(rad), sin(rad)) * circle_radius)
	
	var tween = Tool.quick_tween(bullet, "global_position", final_pos, 6, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
	await tween.finished
	bullet.set_speed(6.5)
	bullet.set_angle(Tool.get_angle_to_player(circle_center_pos))
	
	
	
