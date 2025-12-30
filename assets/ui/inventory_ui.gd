extends VBoxContainer

signal item_hovered(item)
signal item_pressed(item)

const HOVER_COMBAT = preload("uid://dku3i7kc8lhey")
const NORMAL_COMBAT = preload("uid://dfp3v14drfldu")
const PRESSED_COMBAT = preload("uid://dw1ecoumkr2uh")


func _ready() -> void:
	update_inventory()
			
func update_inventory():
	for child in get_children():
		child.queue_free()
	
	for c in Database.inventory:
		if c.amount_held > 0:
			var button = Button.new()
			button.add_theme_stylebox_override("hover", HOVER_COMBAT)
			button.add_theme_stylebox_override("normal", NORMAL_COMBAT)
			button.add_theme_stylebox_override("pressed", PRESSED_COMBAT)
			
			button.text = c.item_name
			button.text += " x" + str(c.amount_held)
			
			# Connect the hover signal to our own handler
			button.mouse_entered.connect(_on_item_button_hovered.bind(c))
			# Connect the pressed signal
			button.pressed.connect(_on_item_button_pressed.bind(c))
			
			self.add_child(button)

func _on_item_button_hovered(c):
	emit_signal("item_hovered", c)

func _on_item_button_pressed(c):
	emit_signal("item_pressed", c)
