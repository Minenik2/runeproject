extends Control

@export var label: Label

func set_damage(amount: int):
	label.text = str(amount)
	modulate = Color(1, 1, 1, 1)
	label.modulate = Color(1, 0.2, 0.2, 1)

	# Create a Tween and animate
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 20, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "queue_free"))

func set_heal(amount: int):
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = "+" + str(amount)
	modulate = Color(1, 1, 1, 1)
	label.modulate = Color(0.2, 1, 0.2, 1)  # Green color for healing

	# Create a Tween and animate
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 20, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "queue_free"))
