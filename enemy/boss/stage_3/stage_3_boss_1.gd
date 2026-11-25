extends Boss

func _init() -> void:
	phases = [
		[ ##Healthbar 1
			preload("uid://dt7a4fhxq1ebx"),
		],
	]

func _ready() -> void:
	super._ready()
