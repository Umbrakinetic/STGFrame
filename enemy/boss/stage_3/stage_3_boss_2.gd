extends Boss

func _init() -> void:
	phases = [
		[ ##Healthbar 1
			preload("uid://bjxy3cjmsrv4u"),
			preload("uid://cdmh8q7o5ku51")
		],
		[ ## Healthbar 2
			preload("uid://csnhd6aa54ft0"),
			preload("uid://blolvoyqvl3um")
		]
	]

func _ready() -> void:
	super._ready()
