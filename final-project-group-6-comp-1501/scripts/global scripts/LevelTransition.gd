extends Node

var playerInventory : Array[gun]


func saveGunToCache(gun):
	playerInventory.append(gun)
	add_child(gun)

func loadGunsFromCache() -> Array:
	var data = []
	for i in playerInventory:
		remove_child(i)
		data.append(i)
	return data
