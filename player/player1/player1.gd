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

@onready var options: = [%Option1, %Option2]
func _shoot():
	var b1: = Danmaku.spawn_bullet(global_position + Vector2(-16, -32), 32, -90, Danmaku.TYPE_SQUARE, Color.PINK, self, 0)
	var b2: = Danmaku.spawn_bullet(global_position + Vector2(16, -32), 32, -90, Danmaku.TYPE_SQUARE, Color.PINK, self, 0)
	for i: Bullet in [b1, b2]:
		Danmaku.set_player_bullet(i, 3)
		i.modulate.a = 0.3
		i.set_size(Vector2(3, 0.5))
		i.started_freeing.connect(bullet_freeing_alpha_change.bind())
	
	if focused:
		for i: Node2D in options:
			var op_b: = Danmaku.spawn_bullet(i.global_position, 30, -90, Danmaku.TYPE_ARROWHEAD, Color.RED, self, 0)
			Danmaku.set_player_bullet(op_b, 1.8)
			op_b.modulate.a = 0.3
			op_b.set_size(Vector2(3, 0.5))
			op_b.started_freeing.connect(bullet_freeing_alpha_change.bind())
	else:
		for i: Node2D in options:
			var op_b: = Danmaku.spawn_bullet(i.global_position, 20, -90, Danmaku.TYPE_SQUARE, Color.RED, self, 0)
			Danmaku.set_player_bullet(op_b, 1.5)
			op_b.modulate.a = 0.3
			op_b.set_behavior(bullet_homing.bind(), [op_b])
			op_b.started_freeing.connect(bullet_freeing_alpha_change.bind())

func bullet_freeing_alpha_change(bullet: Bullet):
	bullet.set_alpha(0.8)

func bullet_homing(args: Array) -> void:
	var b: Bullet = args[0]
	var s = b.speed
	while b != null:
		await get_tree().physics_frame
		if b == null or get_tree() == null: break
		
		var enemies = get_tree().get_nodes_in_group("enemy")
		if enemies.is_empty(): 
			continue
		
		var closest = Tool.sort_closest(enemies, b.global_position)[0]
		b.velocity = b.velocity.lerp(b.global_position.direction_to(closest.global_position) * 60 * 16, 0.2)
		b.velocity.clamp(Vector2(-16, -16), Vector2(16, 16))

func _bomb():
	var bomb_scene = preload("uid://dwkqrejr5v000").instantiate()
	bomb_scene.player = self
	Gametray.add_child(bomb_scene)
	bomb_scene.global_position = global_position
