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
		if node is MatchInfoComponent:
			var arr = _generate_matcher_items.get(node.match_count, [])
			arr.append(node)
			_generate_matcher_items[node.match_count] = arr
			continue
		if node is InfoComponent:
			_generate_dynamic_items.append(node)
			
	if _generate_dynamic_items.is_empty():
		print("Error. Generator node has not a nodes with components for dynamics.")
	if _generate_matcher_items.is_empty():
		print("Error. Generator node has not a nodes with components for matchers.")
	
func generate_item()->Node2D:
	if not _generate_dynamic_items.is_empty():
		var random_item = _generate_dynamic_items.pick_random()
		var item = random_item.duplicate()
		item.position = Vector2i.ZERO
		return item
	return null
	
# direct_h - должен ли предмет иметь ориентацию?
func generate_matcher(match_count:int, direct_h:bool = true)->Node2D:
	if not _generate_matcher_items.is_empty():
		# предметы подходять по количеству предметов для матча
		var arr = _generate_matcher_items.get(match_count, []) as Array
		for node in arr:
			# ищем в списке матчер с нужной ориентацией
			if node is MatchInfoComponent and node.direct_h == direct_h:
				var item = node.duplicate()
				item.global_position = Vector2i.ZERO
				return item
		# в списке нет матчера с указанной ориентацией, берем первый из списка.
		if not arr.is_empty():
			var item = arr.front().duplicate()
			item.global_position = Vector2i.ZERO
			return item
		
	return null
