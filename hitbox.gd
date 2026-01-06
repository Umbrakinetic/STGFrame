@tool
class_name Hitbox
extends Area2D

@export var radius: float = 16:
	set(value):
		radius = value
		$CollisionShape2D.shape.radius = value
