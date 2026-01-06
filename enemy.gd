class_name Enemy
extends CharacterBody2D

enum ItemTypes {
	POWER,
	BIG_POWER,
	POINT,
	LIFE,
	BOMB
}

@export var health: float = 100

@export var drops: Dictionary [ItemTypes, int]

@onready var player = Tool.player

var invincible: bool = false

signal died

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()

var dying: bool = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Bullet and body.is_in_group("playerbullet"):
		body.start_free()
		_damaged()
		if invincible: return
		health -= body.get_meta("Damage")
		if health <= 0 and not dying:
			dying = true 
			_on_death()
			

func _damaged():
	pass

func _on_death() -> void:
	died.emit()
	give_drops()
	queue_free()

func give_drops() -> void:
	for type in drops:
		for count in drops[type]:
			pass
			##add item spawning

func wait(time_sec) -> void:
	if not is_inside_tree(): await tree_entered
	await get_tree().create_timer(time_sec, false, true).timeout

func set_behavior(behavior:Callable, args: Array) -> void:
	behavior.call(args)
