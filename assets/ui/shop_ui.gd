extends CanvasLayer

const ITEM_ICON = preload("uid://djk82ptcej3wt")
const MERCHANT_01 = preload("uid://dxmcj57q3vp2a") # just for testing merchants

var currentMerchant: BaseMerchantStrategy

func _ready() -> void:
	MERCHANT_01.generateInventory()
	setUpShop(MERCHANT_01)
	setUpInventoryPlayer()
	updateGoldLabel()

func updateGoldLabel():
	%goldLabel.text = str(Database.gold) + " Gold"

# takes in an already made merchantStrategy
func setUpShop(merchantInv: BaseMerchantStrategy):
	for child in %listItemUI.get_children():
		child.queue_free()
	currentMerchant = merchantInv
	for item in merchantInv.merchant_inventory:
		if item.stock > 0:
			var newItemUI = ITEM_ICON.instantiate()
			newItemUI.set_item(item)
			newItemUI.pressed.connect(on_merchant_buy.bind(item))
			%listItemUI.add_child(newItemUI)

func setUpInventoryPlayer():
	for child in %listInventoryUI.get_children():
		child.queue_free()
	for item: BaseItemStrategy in Database.inventory:
		if item.amount_held > 0:
			var itemAsStock = sellItem.new(item, item.amount_held)
			var newItemUI = ITEM_ICON.instantiate()
			newItemUI.set_item(itemAsStock)
			newItemUI.pressed.connect(on_player_sell.bind(itemAsStock))
			%listInventoryUI.add_child(newItemUI)

func on_player_sell(item: sellItem):
	Music.play_shop()
	item.item.amount_held -= 1
	Database.gold += item.item.value
	var newItem = sellItem.new(item.item,1)
	var foundItemInMerchant = false
	for merchantItem in currentMerchant.merchant_inventory:
		if merchantItem.item.item_name == newItem.item.item_name:
			merchantItem.stock += 1
			foundItemInMerchant = true
	if !foundItemInMerchant:
		currentMerchant.merchant_inventory.append(newItem)
	setUpShop(currentMerchant)
	setUpInventoryPlayer()
	updateGoldLabel()

func on_merchant_buy(item: sellItem):
	if item.item.value <= Database.gold and item.stock > 0:
		Music.play_shop()
		item.item.amount_held += 1
		Database.gold -= item.item.value
		item.stock -= 1
		setUpShop(currentMerchant)
		setUpInventoryPlayer()
		updateGoldLabel()
	else:
		Music.play_invalid()


func _on_talk_button_pressed() -> void:
	Music.play_ui_hit()
	%dialogue.text = currentMerchant.talk()


func _on_leave_pressed() -> void:
	Music.play_ui_hit()
	hide()
	UiManager.closeUi(self)
