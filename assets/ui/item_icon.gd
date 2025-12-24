extends Button
class_name ItemIcon

func set_item(item: sellItem):
	$HBoxContainer2/Name.text = item.item.item_name
	$HBoxContainer2/stock.text = "x" + str(item.stock)
	$HBoxContainer2/price.text = str(item.item.value)
	$HBoxContainer2.tooltip_strings.append(item.item.effectText())
