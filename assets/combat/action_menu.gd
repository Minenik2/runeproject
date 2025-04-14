extends VBoxContainer

signal action_selected(action_name)

func _ready():
	var actions = ["Attack", "Item"]
	for action in actions:
		var btn = Button.new()
		btn.text = action
		btn.connect("pressed", Callable(self, "_on_action_pressed").bind(action))
		add_child(btn)

func _on_action_pressed(action_name):
	emit_signal("action_selected", action_name)
