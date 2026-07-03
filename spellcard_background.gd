extends Node2D

var alpha: float = 1:
	set(value):
		alpha = value
		modulate.a = value

var tween: Tween

var boss: Enemy:
	set(value):
		boss = value
		
		boss.spell_declared.connect(
		func(arg1: String):
			fade_in()
	)
		boss.phase_ended.connect(
			func():
				if alpha > 0:
					fade_out()
		)

func _ready() -> void:
	alpha = 0
	

func _process(delta: float) -> void:
	$Sprite2D.region_rect.position.y += 0.75

func fade_in():
	if tween != null: tween.kill()
	tween = Tool.quick_tween(self, "alpha", 1, 1, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)

func fade_out():
	if tween != null: tween.kill()
	Tool.quick_tween(self, "alpha", 0, 0.25, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)
