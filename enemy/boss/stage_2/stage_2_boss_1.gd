extends Boss

func _init() -> void:
	phases = [
		[ ##Healthbar 1
			preload("uid://csnhd6aa54ft0"),
			preload("uid://blolvoyqvl3um")
		],
	]

func _ready() -> void:
	super._ready()
