class_name MoneyLabel
extends Label3D


@export var math_label: Label3D


func setup(base_money: float, multiplier: float):
	math_label.text = str(int(multiplier)," x $", int(base_money))
	text = str("$",int(multiplier*base_money))


func _process(delta):
	global_position.y += delta
	modulate.a -= delta
	outline_modulate.a -= delta
	math_label.modulate.a -= delta
	math_label.outline_modulate.a -= delta
	if modulate.a <= 0.0:
		queue_free()
