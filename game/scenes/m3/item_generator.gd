# Генератор предметов. К этому узлу через вызов группы обращаются за генерацией экземпляров узлов.
# Узлы можно создавать в рантайме ререз инициализацию упакованной сцены или дупликацией уже существующего узла.
# В случаес с дупликацией мы уже имеем в сцене инициализированный набор нужных узлов у которых отключена видимость.
# При отключенной видимости у узлов не активна функция компонент. На старте - узел проверяет дочерние
# узлы и сортирует их в контейнеры по типам и в словари по именам.

extends Node

class_name ItemGenerator

var _items:Array[InfoComponent]
var _matche_items:Array[MatchInfoComponent]
var _match_name_equal_enum:Dictionary

func _ready() -> void:
	_items.clear()
	_matche_items.clear()
	
	for node in get_children():
		if node is MatchInfoComponent:
			_matche_items.append(node)
			_match_name_equal_enum[node.get_match_type()] = node.get_item_name()
		elif node is InfoComponent:
			_items.append(node)
	
	if _items.is_empty():
		print("Error. Generator node has not a nodes with components for dynamics.")
	if _matche_items.is_empty():
		print("Error. Generator node has not a nodes with components for matchers.")
		
func get_random_item(exclude:String = "")->String:
	if not exclude.is_empty():
		while true:
			var _name = _items.pick_random().get_item_name()
			if _name != exclude:
				return _name
				
	return _items.pick_random().get_item_name()

func _get_from(_arr:Array, _name:String = "")->InfoComponent:
	if not _arr.is_empty():
		var new_item:InfoComponent = null
		if _name.is_empty():
			new_item = _arr.pick_random().duplicate()
		for item in _arr:
			if item.get_item_name() == _name:
				new_item = item.duplicate()
				break
		if new_item != null:
			new_item.position = Vector2i.ZERO
			return new_item
	return null

func get_item(item_name:String = "")->InfoComponent:
	return _get_from(_items, item_name)
	
func get_matcher(item_name:String = "")->MatchInfoComponent:
	return _get_from(_matche_items, item_name)
	
func get_matcher_from_enum(_match_type:MatcherComponent.EMatcher)->MatchInfoComponent:
	if _match_name_equal_enum.has(_match_type):
		return _get_from(_matche_items, _match_name_equal_enum[_match_type])
	return null

func is_item_name_matcher(item_name:String)->bool:
	for item in _matche_items:
		if item.get_item_name() == item_name:
			return true
	return false
	
func is_item_name_item(item_name:String)->bool:
	for item in _items:
		if item.get_item_name() == item_name:
			return true
	return false
