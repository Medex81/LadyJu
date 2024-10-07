extends Control

func _ready():
	M3Core.items = {
	Item.EItem.RED: preload("res://game/scenes/match3/items/item_red.tscn"),
	Item.EItem.BLUE: preload("res://game/scenes/match3/items/item_blue.tscn"),
	Item.EItem.GREEN: preload("res://game/scenes/match3/items/item_green.tscn"),
	Item.EItem.PURPLE: preload("res://game/scenes/match3/items/item_purple.tscn"),
	Item.EItem.WHITE: preload("res://game/scenes/match3/items/item_white.tscn"),
	Item.EItem.YELLOW: preload("res://game/scenes/match3/items/item_yellow.tscn"),
	
	Item.EItem.ROCKET_LINE_H: preload("res://game/scenes/match3/items/item_rocket_h.tscn"),
	Item.EItem.ROCKET_LINE_V: preload("res://game/scenes/match3/items/item_rocket_v.tscn"),
	Item.EItem.BOMB: preload("res://game/scenes/match3/items/item_bomb2.tscn"),
	Item.EItem.AMULET: preload("res://game/scenes/match3/items/item_amulet.tscn"),
	Item.EItem.BOMB_TOTAL: preload("res://game/scenes/match3/items/item_total_bomb.tscn"),
	
	Item.EItem.GLASS: preload("res://game/scenes/match3/items/item_glass.tscn"),
	Item.EItem.CHAIN: preload("res://game/scenes/match3/items/item_chain.tscn")
}
