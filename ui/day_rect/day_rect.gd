class_name DayRect
extends ColorRect


@export var day_label: Label

var day: int = 1

var day_tween: Tween


func next_day():
	await show_day(day + 1)


func show_day(day: int):
	self.day = day
	day_label.text = str("Day ", day)
	if day_tween and day_tween.is_running():
		day_tween.kill()
	day_tween = create_tween()
	day_tween.tween_property(self, "modulate:a", 1.0, 1.3)
	day_tween.tween_callback(_on_day_shown)
	day_tween.tween_property(self, "modulate:a", 0.0, 1.3)
	await day_tween.finished


func _ready():
	modulate.a = 0.0


func _on_day_shown():
	pass
