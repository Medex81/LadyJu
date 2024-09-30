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
@onready var _type = get_item_type(_item)
const c_move = "Move"
const c_scale = "Scale"
const c_delete = "ScaleToZero"

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
	
static func get_item_type(item:Item.EItem)->Item.EItemType:
	var type:Item.EItemType = Item.EItemType.NONE
	if item > EItem.NONE and item < EItem.ROCKET_LINE_H:
		type = EItemType.COMMON
	if item > EItem.YELLOW and item < EItem.GLASS:
		type = EItemType.MATCHED
	if item > EItem.BOMB_TOTAL:
		type = EItemType.BLOCKED
	return type

func hints():
	var node_scale = Components.get_component(self, c_scale)
	if node_scale:
		node_scale.exec()

func hint_stop():
	var node_scale = Components.get_component(self, c_scale)
	if node_scale:
		node_scale.abort(true)
	
func is_component_running()->bool:
	var node = Components.get_component(self, c_move)
	return node and node.is_running()
	
func move(to_position:Vector2):
	var node_move = Components.get_component(self, c_move)
	if node_move:
		node_move.exec(to_position)
		
func delete():
	var node_scale = Components.get_component(self, c_delete)
	if node_scale:
		node_scale.exec()

func _on_anim_send_start(component):
	print("anim_send_start item ", component)
	M3Core.add_event()
	
func _on_anim_send_end(component):
	print("anim_send_end item ", component)
	M3Core.done_event()

func _on_scale_to_zero_send_end(component):
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	_on_anim_send_end(component)
	queue_free()
