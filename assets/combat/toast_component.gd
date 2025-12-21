extends Node

@onready var ui: Control = $"../../CanvasLayer/UI"

func show_damage_number(amount: int, position: Vector2):
	var label = Label.new()
	label.text = str(amount)
	label.modulate = Color(1, 0.2, 0.2)
	label.add_theme_font_size_override("font_size", 24)
	label.position = position
	ui.add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", position.y - 30, 0.6)
	tween.tween_property(label, "modulate:a", 0, 0.6)
	tween.connect("finished", Callable(label, "queue_free"))

func show_crit_damage_number(amount: int, position: Vector2):
	var label = Label.new()
	label.text = str(amount) + "!"
	label.modulate = Color(1, 1, 0)  # Yellow for crit
	label.add_theme_font_size_override("font_size", 28)
	label.position = position
	ui.add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", position.y - 40, 0.6)
	tween.tween_property(label, "modulate:a", 0, 0.6)
	tween.connect("finished", Callable(label, "queue_free"))
