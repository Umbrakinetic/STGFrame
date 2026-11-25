extends Player

func _ready() -> void:
	%OptionPosition.global_position = global_position

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	var a = [
		[%Option1, %Option1Unfocused, %Option1Focused],
		[%Option2, %Option2Unfocused, %Option2Focused],
	]
	for i in a:
		if focused:
			i[0].global_position = lerp(i[0].global_position, i[2].global_position, 0.25)
		else:
			i[0].global_position = lerp(i[0].global_position, i[1].global_position, 0.25)
	
	%OptionPosition.global_position = lerp(%OptionPosition.global_position, global_position, 0.2)
	for option in %OptionPosition.get_children():
		option.rotation_degrees += 4

## for speedkilling enemies when replaying and testing certain parts of a stage.
const DEBUG_DAMAGE_BOOST = 1

@onready var options: = [%Option1, %Option2]
func _shoot():
	var b1: = Danmaku.spawn_bullet(global_position + Vector2(-16, -32), 32, -90, Danmaku.TYPE_SQUARE, Color.PINK, self, 0)
	var b2: = Danmaku.spawn_bullet(global_position + Vector2(16, -32), 32, -90, Danmaku.TYPE_SQUARE, Color.PINK, self, 0)
	for i: Bullet in [b1, b2]:
		Danmaku.set_player_bullet(i, 3 * DEBUG_DAMAGE_BOOST)
		i.modulate.a = 0.3
		i.set_size(Vector2(3, 0.5))
		i.started_freeing.connect(bullet_freeing_alpha_change.bind())
	
	if focused:
		for i: Node2D in options:
			var op_b: = Danmaku.spawn_bullet(i.global_position, 30, -90, Danmaku.TYPE_ARROWHEAD, Color.RED, self, 0)
			Danmaku.set_player_bullet(op_b, 1.8 * DEBUG_DAMAGE_BOOST)
			op_b.modulate.a = 0.3
			op_b.set_size(Vector2(3, 0.5))
			op_b.started_freeing.connect(bullet_freeing_alpha_change.bind())
	else:
		for i: Node2D in options:
			var op_b: = Danmaku.spawn_bullet(i.global_position, 20, -90, Danmaku.TYPE_SQUARE, Color.RED, self, 0)
			Danmaku.set_player_bullet(op_b, 1.5 * DEBUG_DAMAGE_BOOST)
			op_b.modulate.a = 0.3
			op_b.set_behavior(bullet_homing.bind(), [op_b, 3000])
			op_b.started_freeing.connect(bullet_freeing_alpha_change.bind())

func bullet_freeing_alpha_change(bullet: Bullet):
	bullet.set_alpha(0.8)

func bullet_homing(args: Array) -> void:
	var b: Bullet = args[0]
	var homing_inertia = args[1]
	var s = b.speed
	while is_instance_valid(b):
		await get_tree().physics_frame
		if b == null or get_tree() == null: break
		
		var enemies = get_tree().get_nodes_in_group("enemy")
		var closest: Vector2
		if enemies.is_empty(): 
			closest = b.global_position + Vector2(0, -16)
		else:
			closest = Tool.sort_closest(enemies, b.global_position)[0].global_position
		
		var delta := get_physics_process_delta_time()
		
		var desired = b.global_position.direction_to(closest) * 60 * 16
		var steering: Vector2 = (desired - b.velocity).limit_length(homing_inertia * delta)
		b.velocity += steering

func _bomb():
	_set_invincibility(3)
	var hue = 0
	for i in 6:
		var b = Danmaku.spawn_bullet(position, 10, randf_range(-180, 0), Danmaku.TYPE_CIRCLEBORDER, Color.from_ok_hsl(hue, 1.0, 0.5))
		Danmaku.set_player_bullet(b, 15)
		b.set_behavior(bullet_homing, [b, 1250])
		b.set_size(b.size * 6)
		b.add_blending = true
		b.cancellable = false
		b.lifetime_frames = 180 - (18 * i)
		
		var b_area = Area2D.new()
		var col = CollisionShape2D.new()
		b.add_child(b_area)
		b_area.add_child(col)
		
		col.shape = CircleShape2D.new()
		col.shape.radius = 50
		b_area.set_collision_mask_value(2, true)
		b_area.set_collision_mask_value(3, true)
		b_area.monitorable = false
		
		bomb_bullet_behavior(b, b_area)
		b.started_freeing.connect(bomb_bullet_expire.bind(b_area))
		
		hue += 1 / 6.0
		await Tool.quick_timer(0.4).timeout
	
	await Tool.quick_timer(1.5).timeout 
	bombing = false

func bomb_bullet_behavior(b: Bullet, a: Area2D):
	while is_instance_valid(b):
		for i in a.get_overlapping_areas():
			if i.get_parent() is Enemy:
				i.get_parent().take_damage(0.4)
				
		for i in a.get_overlapping_bodies():
			if i is Bullet and not i.is_in_group("playerbullet") and i.cancellable:
				i.start_free()
		
		await get_tree().physics_frame

func bomb_bullet_expire(b: Bullet, a: Area2D):
	for i in a.get_overlapping_areas():
			if i.get_parent() is Enemy:
				i.get_parent().take_damage(25)
	
	for i: Bullet in Gametray.bullet_list:
		if i.global_position.distance_to(b.global_position) < 384 and not i.is_in_group("playerbullet"):
			i.start_free()
