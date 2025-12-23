extends Control
class_name ShopUI

func _on_tab_changed(tab: int) -> void:
	Music.play_ui_hit()
