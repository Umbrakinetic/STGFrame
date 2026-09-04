extends Player

func _ready() -> void:
	%OptionPosition.global_position = global_position


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	for i in player_lasers:
		i.get_node("Sprite2D").region_rect.position.x += 8
	
	var areas = %PlayerLaser1.get_overlapping_areas() + %PlayerLaser2.get_overlapping_areas()
	for i in areas:
		var parent = i.get_parent()
		if parent is Enemy:
			parent.take_damage(1.5)
	
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
	

func _unfocused():
	if shooting and can_shoot: show_lasers()
func _focused():
	if shooting: hide_lasers()
	

func started_shooting():
	if not focused:
		show_lasers()

func stopped_shooting():
	hide_lasers()

@onready var options: = [%Option1, %Option2]
func _shoot():
	pass
	var b1: = Danmaku.spawn_bullet(global_position + Vector2(-16, -32), 32, -90, Danmaku.TYPE_ARROWHEAD, Color.MEDIUM_SPRING_GREEN, self, 0)
	var b2: = Danmaku.spawn_bullet(global_position + Vector2(16, -32), 32, -90, Danmaku.TYPE_ARROWHEAD, Color.MEDIUM_SPRING_GREEN, self, 0)
	for i: Bullet in [b1, b2]:
		Danmaku.set_player_bullet(i, 3)
		i.modulate.a = 0.3
		i.set_size(Vector2(3, 1))
		i.started_freeing.connect(bullet_freeing_alpha_change.bind())
	
	#if focused:
		#for i: Node2D in options:
			#var op_b: = Danmaku.spawn_bullet(i.global_position, 30, -90, Danmaku.TYPE_ARROWHEAD, Color.RED, self, 0)
			#Danmaku.set_player_bullet(op_b, 1.8)
			#op_b.modulate.a = 0.3
			#op_b.set_size(Vector2(3, 0.5))
			#op_b.started_freeing.connect(bullet_freeing_alpha_change.bind())
	#else:
		#for i: Node2D in options:
			#var op_b: = Danmaku.spawn_bullet(i.global_position, 20, -90, Danmaku.TYPE_SQUARE, Color.RED, self, 0)
			#Danmaku.set_player_bullet(op_b, 1.5)
			#op_b.modulate.a = 0.3
			#op_b.started_freeing.connect(bullet_freeing_alpha_change.bind())

func bullet_freeing_alpha_change(bullet: Bullet):
	bullet.set_alpha(0.8)

@onready var player_lasers: Array = [%PlayerLaser1, %PlayerLaser2]
var l_tween: Tween
func show_lasers():
	for i in player_lasers:
		i.get_node("CollisionShape2D").disabled = false
	if l_tween != null: l_tween.kill()
	l_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	l_tween.tween_property(%PlayerLaser1, "scale:x", 1, 0.3)
	l_tween.parallel().tween_property(%PlayerLaser2, "scale:x", 1, 0.3)

func hide_lasers():
	for i in player_lasers:
		i.get_node("CollisionShape2D").disabled = true
	if l_tween != null: l_tween.kill()
	l_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	l_tween.tween_property(%PlayerLaser1, "scale:x", 0, 0.3)
	l_tween.parallel().tween_property(%PlayerLaser2, "scale:x", 0, 0.3)

func _bomb():
	var bomb_scene = preload("uid://c1pp7jaoyprk8").instantiate()
	bomb_scene.player = self
	Gametray.add_child(bomb_scene)
	bomb_scene.global_position = global_position
