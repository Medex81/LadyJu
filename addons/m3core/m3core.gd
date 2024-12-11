extends Node

var _generate_dynamic_items:Array[AreaItem]
var _generate_matcher_items:Array[AreaItem]
# сохраняем имена всех предметов для проверки дублирования имён
var _generate_item_names:Array[String]

#func start():
	## Для запуска предметов необходимо, чтобы все дочерние узлы были проинициализированы.
	## В текущей функции будут вызваны методы инициализиции всех дочерних узлов.
	## Нужно подождать выхода из метода с помощью корутины и сообщить всем предметам о том, что можно двигаться. 
	#await get_tree().create_timer(0.5).timeout
	#get_tree().call_group("items", "check_move")

func set_generate_items(container_node:Node):
	_generate_dynamic_items.clear()
	_generate_matcher_items.clear()
	_generate_item_names.clear()
	
	if container_node:
		for node in container_node.get_children():
			if node is AreaItem:
				if _generate_item_names.has(node.item_name):
					print("Error. Item name duplicated {0}.".format([node.item_name]))
					continue
				match node.get_item_type():
					AreaItem.EItemTypes.DYNAMIC:
						_generate_dynamic_items.append(node)
					AreaItem.EItemTypes.MATCHER:
						_generate_matcher_items.append(node)
				_generate_item_names.append(node.item_name)
						
func generate_item(item_name:String = "")->AreaItem:
	if item_name.is_empty():
		if not _generate_dynamic_items.is_empty():
			return _generate_dynamic_items.pick_random().duplicate()
		print("Error. _generate_dynamic_items list is empty.")
	else:
		for item in _generate_dynamic_items:
			if item.item_name == item_name:
				return item.duplicate()
		print("Error. Doesnt exist item with name {0}.".format([item_name]))
	return null
	
func generate_matcher(match_count:int)->AreaItem:
	for matcher in _generate_matcher_items:
		if matcher.get_item_generate_count() == match_count:
			return matcher.duplicate()
	print("Error. Doesnt exist matcher with count {0}.".format([match_count]))
	return null
 
func process_match(item:AreaItem, items:Array[AreaItem]):
	var size = items.size()
	if size == 2:
		return
	size += 1
	var gen_matcher = generate_matcher(size)
	if gen_matcher:
		gen_matcher.position = item.position
		item.get_parent().add_child(gen_matcher)
		gen_matcher.active_move_timer = true
		

