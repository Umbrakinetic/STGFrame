extends CharacterBody2D

var lives: int = 2:
	set(value):
		lives = value
		resources_updated.emit()

var bombs_per_life: int = 3
var bombs: int = bombs_per_life:
	set(value):
		bombs = value
		resources_updated.emit()
var bombing: bool = false

var default_speed: float = 400
var can_move : bool = true
var can_shoot: bool = true
var can_bomb : bool = true

var focused: bool = false
var shooting: bool = false
var respawning: bool = false
var direction: Vector2
var invincible: bool = false:
	set(value):
		invincible = value
		%Hitbox.monitoring = not value
		%Grazebox.monitoring = not value
var speed: float = default_speed

signal died
signal bombed
signal resources_updated
signal grazed

signal lost

var focus_tween: Tween

func _unhandled_input(event: InputEvent) -> void:
	direction = Input.get_vector("ui_left", "ui_right","ui_up","ui_down") * int(can_move)
	
	if event.is_action_pressed("focus"):
		focused = true
		speed = default_speed / 2
		change_focus_scale(0.2, Vector2.ONE)
	elif event.is_action_released("focus"):
		focused = false
		speed = default_speed
		change_focus_scale(0.2, Vector2.ZERO)
	
	if event.is_action_pressed("shoot"):
		shooting = true
	elif event.is_action_released("shoot"):
		shooting = false
	
	if event.is_action_pressed("bomb") and bombs > 0 and not bombing and not respawning and can_bomb:
		bombs -= 1
		bombing = true
		emit_signal("bombed")
		
		var bomb = preload("uid://dwkqrejr5v000").instantiate()
		bomb.player = self
		Gametray.add_child(bomb)
		bomb.global_position = global_position
		

func change_focus_scale(time: float, sprite_scale: Vector2) -> void:
	if focus_tween != null: focus_tween.kill()
	focus_tween = create_tween()
	focus_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	focus_tween.tween_property(%GrazeboxSprite, "scale", sprite_scale, time)
	focus_tween.parallel().tween_property(%HitboxSprite, "scale", sprite_scale, time)

var iframe_blink: int = 0
var frame_c: int = 0
func _physics_process(delta: float) -> void:
	frame_c += 1
	
	if not frame_c % 8:
		%Sprite.frame = (%Sprite.frame + 1) % 8
	
	%GrazeboxSprite.rotation_degrees += 1.5
	for option in %OptionPosition.get_children():
		option.rotation_degrees += 4
	
	
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
	
	velocity = direction * delta * 60 * speed
	var collision: = move_and_slide()
	
	if invincible:
		iframe_blink += 1
		if not iframe_blink % 5:
			visible = not visible
	if not invincible and not visible:
		show()
	
	if shooting and not frame_c % 4 and not respawning:
		shoot(-16)
		shoot(16)
		%ShootSound.play()

@onready var options: = [%Option1, %Option2]
func shoot(x_offset: float):
	var b: = Danmaku.spawn_bullet(global_position + Vector2(x_offset, -32), 32, -90, Danmaku.TYPE_ARROWHEAD, Color.PINK, self, 0)
	Danmaku.set_player_bullet(b)
	b.modulate.a = 0.4
	b.set_size(Vector2(3, 0.5))
	
	if focused:
		for i: Node2D in options:
			var op_b: = Danmaku.spawn_bullet(i.global_position, 30, -90, Danmaku.TYPE_ARROWHEAD, Color.RED, self, 0)
			Danmaku.set_player_bullet(op_b, 1.8)
			op_b.modulate.a = 0.3
	else:
		for i: Node2D in options:
			var op_b: = Danmaku.spawn_bullet(i.global_position, 20, -90, Danmaku.TYPE_SQUARE, Color.RED, self, 0)
			Danmaku.set_player_bullet(op_b, 1.5)
			op_b.modulate.a = 0.3
			op_b.set_behavior(bullet_homing.bind(), [op_b])

func bullet_homing(args: Array) -> void:
	var b: Bullet = args[0]
	var s = b.speed
	while b != null:
		await get_tree().physics_frame
		if b == null: break
		
		var enemies = get_tree().get_nodes_in_group("enemy")
		if enemies.is_empty(): 
			continue
		
		var closest = Tool.sort_closest(enemies, b.global_position)
		b.velocity = b.velocity.lerp(b.global_position.direction_to(closest.global_position) * 60 * 16, 0.2)
		b.velocity.clamp(Vector2(-16, -16), Vector2(16, 16))
		#b.velocity += b.global_position.direction_to(closest.global_position) * 20

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Bullet and not body.is_in_group("playerbullet") == true and not invincible:
		%DeathSound.play()
		body.start_free()
		set_deferred("invincible", true)
		for i in 8:
			await get_tree().physics_frame
		if bombing: return
		die()
		


func die():
	lives -= 1
	emit_signal("died")
	
	%Sprite.hide()
	respawning = true
	invincible = true
	can_move = false
	
	await get_tree().create_timer(1, false, true).timeout
	if lives < 0:
		get_tree().quit()
	
	bombs = max(bombs, bombs_per_life)
	
	position = Vector2(0, 512)
	%Sprite.show()
	respawning = false
	can_move = true
	await get_tree().create_timer(3, false, true).timeout
	invincible = false
	
	show()


func _on_grazebox_body_entered(body: Node2D) -> void:
	if body is Bullet and not body.is_in_group("playerbullet") and not body.is_in_group("grazed"):
		body.add_to_group("grazed")
		emit_signal("grazed")
