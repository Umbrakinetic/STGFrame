class_name Player
extends CharacterBody2D

## The player's number of starting lives.[br]
## if lives is at 0 when player dies, the "Game Over" menu appears.
var lives: int = 2:
	set(value):
		lives = value
		resources_updated.emit()

## How many bombs the player has by default when spawning or respawning.
var bombs_per_life: int = 3

## The player's starting number of bombs. [br]
## When player dies, the value is set to bombs_per_life.
var bombs: int = bombs_per_life:
	set(value):
		bombs = value
		resources_updated.emit()

## Whether the player is currently using a bomb.
var bombing: bool = false


var default_speed: float = 400
var can_move : bool = true
var can_shoot: bool = true:
	set(value):
		can_shoot = value
		if not can_shoot: 
			shooting = false
var can_bomb : bool = true

var focused: bool = false:
	set(value):
		focused = value
		if focused:
			_focused()
		else:
			_unfocused()
func _focused():
	pass
func _unfocused():
	pass

var shooting: bool = false:
	set(value):
		if not can_shoot: 
			shooting = false
		else:
			if shooting == false and value == true:
				started_shooting()
			elif shooting == true and value == false:
				stopped_shooting()
			shooting = value
			
				

func started_shooting():
	pass
func stopped_shooting():
	pass

var respawning: bool = false
var movement_input_direction: Vector2
var invincible: bool = false:
	set(value):
		invincible = value
		%Hitbox.set_collision_mask_value(3, not value)
		%Grazebox.set_collision_mask_value(3, not value)
var speed: float = default_speed

signal died
signal bombed
signal resources_updated
signal grazed

signal lost

var focus_tween: Tween

func _unhandled_input(event: InputEvent) -> void:
	movement_input_direction = Input.get_vector("ui_left", "ui_right","ui_up","ui_down") * int(can_move)
	
	if event.is_action_pressed("focus"):
		focused = true
		speed = default_speed / 2
		change_focus_scale(0.2, Vector2.ONE)
		$ItemAutoCollectRange/CollisionShape2D.disabled = false
	elif event.is_action_released("focus"):
		focused = false
		speed = default_speed
		change_focus_scale(0.2, Vector2.ZERO)
		$ItemAutoCollectRange/CollisionShape2D.disabled = true
	if event.is_action_pressed("shoot"):
		shooting = true
	elif event.is_action_released("shoot"):
		shooting = false
	
	if event.is_action_pressed("bomb") and bombs > 0 and not bombing and not respawning and can_bomb:
		_collect_all_items()
		bombs -= 1
		bombing = true
		emit_signal("bombed")
		
		_bomb()

func _bomb():
	pass

func change_focus_scale(time: float, sprite_scale: Vector2) -> void:
	if focus_tween != null: focus_tween.kill()
	focus_tween = create_tween()
	focus_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	focus_tween.tween_property(%GrazeboxSprite, "scale", sprite_scale, time)
	focus_tween.parallel().tween_property(%HitboxSprite, "scale", sprite_scale, time)

var iframe_blink: int = 0
var frame_count: int = 0

var invincibility_time_left: float = 0

var laser_graze_delay: int = 0

func _physics_process(delta: float) -> void:
	frame_count += 1
	
	laser_graze_delay += 1
	
	if laser_graze_delay % 8 == 0:
		for i in %Grazebox.get_overlapping_areas():
			if i is Laser and not i.is_in_group("playerbullet"):
				grazed.emit()
	
	%GrazeboxSprite.rotation_degrees += 1.5

	
	
	%InvincibilityIndicator.rotation_degrees -= 1.5
	%InvincibilityIndicator.scale = Vector2.ONE * min(%InvincibilityTimer.time_left, 1)
	
	velocity = movement_input_direction * delta * 60 * speed
	var collision: = move_and_slide()
	
	if invincible:
		iframe_blink += 1
		if not iframe_blink % 5:
			visible = not visible
	if not invincible and not visible:
		show()
	
	if shooting and not frame_count % 4 and not respawning and not bombing:
		_shoot()
		%ShootSound.play()

func _shoot():
	pass

var hit_this_frame: bool = false
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Bullet and not body.is_in_group("playerbullet") == true and \
	not invincible and not hit_this_frame:
		hit_this_frame = true
		can_move = false
		%DeathSound.play()
		body.start_free()
		set_deferred("invincible", true)
		for i in 8:
			await get_tree().physics_frame
		if bombing: 
			can_move = true
			return
		can_shoot = false
		_die()
		
		await get_tree().physics_frame
		hit_this_frame = false

func _on_hitbox_area_entered(area: Node2D) -> void:
	if area is Laser and not area.is_in_group("playerbullet") == true and \
	not invincible and not hit_this_frame:
		hit_this_frame = true
		can_move = false
		%DeathSound.play()
		set_deferred("invincible", true)
		for i in 8:
			await get_tree().physics_frame
		if bombing: 
			can_move = true
			return
		_die()
		
		await get_tree().physics_frame
		hit_this_frame = false

func _die():
	lives -= 1
	emit_signal("died")
	
	%Sprite.hide()
	_set_invincibility(4)
	respawning = true
	
	await Tool.quick_timer(1).timeout
	
	bombs = max(bombs, bombs_per_life)
	
	position = Vector2(0, 512)
	%Sprite.show()
	respawning = false
	can_move = true
	can_shoot = true
	await Tool.quick_timer(3).timeout
	
	show()

func _set_invincibility(time: float):
	invincible = true
	if time > %InvincibilityTimer.time_left:
		%InvincibilityTimer.start(time)
func _on_invincibility_timer_timeout() -> void:
	invincible = false

func _on_grazebox_body_entered(body: Node2D) -> void:
	if body is Bullet and not body.is_in_group("playerbullet") and not body.is_in_group("grazed"):
		body.add_to_group("grazed")
		emit_signal("grazed")


func _on_grazebox_area_entered(area: Area2D) -> void:
	if area is Item:
		area.queue_free()

func _collect_all_items():
	for i in get_tree().get_nodes_in_group("item"):
		i.tracking_player = true


func _on_item_auto_collect_area_entered(area: Area2D) -> void:
	if area is Item:
		area.tracking_player = true
