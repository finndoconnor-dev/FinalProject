extends Node

var playerInventory : Array[gun]


func saveGunToCache(gun):
	if playerInventory.has(gun):
		return
	playerInventory.append(gun)
	add_child(gun)

func loadGunsFromCache() -> Array:
	var data = []
	for i in playerInventory:
		if i.get_parent() == self:
			remove_child(i)
		data.append(i)
	playerInventory.clear()
	return data
