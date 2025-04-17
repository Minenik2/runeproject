extends VBoxContainer

func _ready() -> void:
	for c in Database.inventory:
		if c.amount_held > 0:
			var button = Button.new()
			
			button.text = c.item_name
			button.text += " x" + str(c.amount_held)
			
			self.add_child(button)
