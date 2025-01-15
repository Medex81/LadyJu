# Генератор предметов. К этому узлу через вызов группы обращаются за генерацией экземпляров узлов.
# Узлы можно создавать в рантайме ререз инициализацию упакованной сцены или дупликацией уже существующего узла.
# В случаес с дупликацией мы уже имеем в сцене инициализированный набор нужных узлов у которых отключена видимость.
# При отключенной видимости у узлов не активна функция компонент. На старте - узел проверяет дочерние
# узлы и сортирует их в контейнеры по типам и в словари по именам.

extends Node

class_name ItemGenerator

var _generate_dynamic_items:Array
var _generate_matcher_items:Dictionary

func _ready() -> void:
	_generate_dynamic_items.clear()
	_generate_matcher_items.clear()
	
	for node in get_children():
		for component in node.get_children():
			if component is MatchInfoComponent:
				var arr = _generate_matcher_items.get(component.match_count, [])
				arr.append(node)
				_generate_matcher_items[component.match_count] = arr
				continue
			if component is InfoComponent:
				_generate_dynamic_items.append(node)
			
	if _generate_dynamic_items.is_empty():
		print("Error. Generator node has not a nodes with components for dynamics.")
	if _generate_matcher_items.is_empty():
		print("Error. Generator node has not a nodes with components for matchers.")
	
func generate_item()->Node2D:
	if not _generate_dynamic_items.is_empty():
		var random_item = _generate_dynamic_items.pick_random()
		var item = random_item.duplicate()
		#remove_child(item)
		return item
	return null
	
func generate_matcher(match_count:int)->Node2D:
	if not _generate_matcher_items.is_empty():
		var arr = _generate_matcher_items.get(match_count, []) as Array
		if not arr.is_empty():
			var item = arr.pick_random().duplicate()
			return item
		
	return null
