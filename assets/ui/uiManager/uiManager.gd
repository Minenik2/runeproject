extends Node

var uiArray = []

func addUi(uiObj):
	uiArray.append(uiObj)

func closeUi(uiObj):
	uiArray.erase(uiObj)

func closeAllUi():
	for ui in uiArray:
		uiArray.pop_back().hide()
