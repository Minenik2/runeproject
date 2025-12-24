extends AudioStreamPlayer

func play_ui_hit():
	$uiHit.play()

func play_ui_hit_combat():
	$uiHitCombat.play()

func play_movedExit():
	$movedInExit.play()

func play_chestOpen(rarity = "common"):
	match rarity:
		"common": $chestOpenCommon.play()
		"rare": $chestOpenRare.play()
		"legendary": $chestOpenLegendary.play()

func play_death():
	$death.play()

func play_shop():
	$uiShop.play()

func play_invalid():
	$uiInvalid.play()
