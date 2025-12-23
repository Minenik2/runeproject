extends Resource
class_name sellItem

var item: BaseItemStrategy
var stock: int

func _init(itemCur: BaseItemStrategy, stockCur: int) -> void:
	item = itemCur
	stock = stockCur
