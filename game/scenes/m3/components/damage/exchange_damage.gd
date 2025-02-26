extends BaseDamageComponent

class_name ExchangeDamageComponent

@export var change_percent:float = 0.5
#@export var damage_timeout:float = 1.0
const group_crystals = "crystals"

func start(item_name = null):
	if item_name is String and not item_name.is_empty():
		var crystals_arr = get_tree().get_nodes_in_group(group_crystals) as Array[InfoComponent]
		var without_arr:Array[InfoComponent]
		for item in crystals_arr:
			if item.get_item_name() != item_name and item.is_active == true:
				without_arr.append(item)
		without_arr.shuffle()
		#print("count ", without_arr.size(), " ", item_name)
		var count = int(without_arr.size() * change_percent)
		while count > 0:
			count -= 1
			var new_item = without_arr[count].change_to(item_name)
			#if new_item != null:
				#var detonator = DetonatorComponent.new()
				#var parent = new_item.get_parent()
				#parent.add_child(detonator)
				#detonator.start(damage_timeout)
	#super.start()
