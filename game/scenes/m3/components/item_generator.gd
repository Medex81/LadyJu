extends Node

class_name ItemGenerator

var _generate_dynamic_items:Array
var _generate_matcher_items:Dictionary

func _ready() -> void:
	_generate_dynamic_items.clear()
	_generate_matcher_items.clear()
	
	for node in get_children():
		for component in node.get_children():
			if component is MoverComponent:
				component.stop_move()
				
			if component is SpecItemComponent:
				var arr = _generate_matcher_items.get(component.match_count, [])
				arr.append(node)
				_generate_matcher_items[component.match_count] = arr
				continue
			
			_generate_dynamic_items.append(node)
			
	if _generate_dynamic_items.is_empty():
		print("Error. Generator node has not a nodes with components for dynamics.")
	if _generate_matcher_items.is_empty():
		print("Error. Generator node has not a nodes with components for matchers.")
	
func generate_item()->Node2D:
	if not _generate_dynamic_items.is_empty():
		var random_item = _generate_dynamic_items.pick_random()
		return random_item.duplicate()
	return null
	
func generate_matcher(match_count:int)->Node2D:
	if not _generate_matcher_items.is_empty():
		var arr = _generate_matcher_items.get(match_count, []) as Array
		if not arr.is_empty():
			return arr.pick_random().duplicate()
		
	return null
