extends Boss

func _init() -> void:
	phases = [
		[ ##Healthbar 1
			preload("uid://bjxy3cjmsrv4u"),
			preload("uid://cdmh8q7o5ku51")
		],
	]

func _ready() -> void:
	super._ready()
