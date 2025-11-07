extends TextureRect

var tageted = false

func hideTarget():
	tageted = false
	$selected.hide()

func showTarget():
	tageted = true
	$selected.show()
