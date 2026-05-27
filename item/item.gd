class_name Item
extends Area2D

var item_gravity: float = 0.098
var initial_velocity: float = -4
var velocity = initial_velocity
var max_velocity: float = 6



var sprite: Danmaku.ItemType:
	set(value):
		sprite = value
		match value:
			Danmaku.ItemType.POINT:
				$ItemSprite.texture = preload("uid://cj2flfxe1v0qw")
			Danmaku.ItemType.POWER:
				$ItemSprite.texture = preload("uid://4jpdwepgww7b")


func _ready() -> void:
	var tween : = Tool.quick_tween(self, "global_rotation_degrees", global_rotation_degrees + 360, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.3)

func _physics_process(delta: float) -> void:
	global_position.y += velocity
	if velocity < max_velocity: velocity += item_gravity
	
