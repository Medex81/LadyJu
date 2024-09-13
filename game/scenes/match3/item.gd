extends Sprite2D

class_name Item

enum EItem{
	NONE,
	# кристаллы
	RED,
	BLUE,
	GREEN,
	PURPLE,
	WHITE,
	#      <- вставлять новые предметы сюда
	YELLOW,
	# сматченные предметы
	ROCKET_LINE_H, # 4, урон по горизонтали на всю длину
	ROCKET_LINE_V,  # 4, урон по вертикали на всю длину
	BOMB, # 5, урон 9 клеток с текущей в центре
	AMULET, # 6, урон по всем клеткам имеющим предмет с которым свапнулись
	#      <- вставлять новые предметы сюда
	BOMB_TOTAL, # 7, урон по всем клеткам
	# блокеры
	GLASS, # стекло накрывающее предмет, не перемещается, разрушается с одного пункта урона
	NODE_NET, # разрушается с 2 пунктов урона
	#      <- вставлять новые предметы сюда
	CHAIN # разрушение с 3 пунктов урона
}

enum EItemType{
	NONE,
	COMMON,
	MATCHED,
	BLOCKED
}

static var _common_type = EItem.RED

# имя предмета в модели
@export var _item = EItem.NONE
var _type = EItemType.NONE


func _ready():
	if _item > EItem.NONE and _item < EItem.ROCKET_LINE_H:
		_type = EItemType.COMMON
	if _item > EItem.YELLOW and _item < EItem.GLASS:
		_type = EItemType.MATCHED
	if _item > EItem.BOMB_TOTAL:
		_type = EItemType.BLOCKED

func get_item()->EItem:
	return _item
	
func get_type()->EItemType:
	return _type
	
func is_common()->bool:
	return _type == EItemType.COMMON
	
func is_matched()->bool:
	return _type == EItemType.MATCHED
	
func is_blocked()->bool:
	return _type == EItemType.BLOCKED
	
func is_valid()->bool:
	return _item != EItem.NONE and _type != EItemType.NONE
	
static func get_next_common()->EItem:
	_common_type += 1
	if _common_type > EItem.YELLOW:
		_common_type = EItem.RED
	return _common_type
