extends VBoxContainer
class_name enemyIcon

var tageted = false
var max_hp = 0
var current_hp = 0

func hideTarget():
	tageted = false
	$enemyTexture/selected.hide()

func showTarget():
	tageted = true
	$enemyTexture/selected.show()

func setTexture(texture: Texture):
	$enemyTexture.texture = texture

func getTexture():
	return $enemyTexture

# hp visual

func setHP(amount):
	$ProgressBar.value = amount
	current_hp = amount
	updateLabel()

func setMaxHP(amount):
	$ProgressBar.max_value = amount
	max_hp = amount
	updateLabel()
	
func updateLabel():
	$ProgressBar/Label.text = "HP: %s/%d" % [
				current_hp, max_hp
			]
