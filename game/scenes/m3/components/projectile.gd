extends BaseMoveComponent

var tween:Tween = null
var to_item:InfoComponent = null
var from_item:InfoComponent = null
var start_global_pos:Vector2
# список с разными целями по квестам для уровня
static var processed_aims:Array[InfoComponent]

func start(_self_item:InfoComponent, _item_name:String = ""):
	if _self_item != null:
		from_item = _self_item
		var quest_item_names:Array[String]
		for item in get_tree().get_nodes_in_group(Quest.group_name):
			if item is Quest and item.is_monitoring and not item.get_item_name().is_empty():
				quest_item_names.append(item.get_item_name())
		if not quest_item_names.is_empty():
			#var random_item_name = quest_item_names.pick_random()
			var current_quest_item_in_field:Array[InfoComponent]
			for info_comp in get_tree().get_nodes_in_group(InfoComponent.group_name):
				if info_comp is InfoComponent and info_comp.is_interactive and info_comp.get_item_name() in quest_item_names\
				# цель не должна быть выбрана другими предметами этого класса - удар по разным целям
				and not info_comp in processed_aims:
					current_quest_item_in_field.append(info_comp)
			if current_quest_item_in_field.is_empty() and not processed_aims.is_empty():
				current_quest_item_in_field.append(processed_aims.front())
				
			if not current_quest_item_in_field.is_empty():
					var random_quest_item:InfoComponent = current_quest_item_in_field.pick_random() as InfoComponent
					if random_quest_item != null:
						to_item = random_quest_item
						processed_aims.append(to_item)
						start_global_pos = random_quest_item.global_position
						run_tween()
			else:
				send_done.emit()

func tween_step(_inx:int):
	if tween != null:
		if to_item == null:
			tween.step_finished.disconnect(tween_step)
			tween.kill()
			call_deferred("start", from_item)
			return
		if start_global_pos != to_item.global_position:
			run_tween()
			
func run_tween():
	if tween != null:
		if tween.step_finished.is_connected(tween_step):
			tween.step_finished.disconnect(tween_step)
		tween.kill()
	tween = get_tree().create_tween()
	tween.step_finished.connect(tween_step)
	tween.tween_property(from_item, "global_position", to_item.global_position, 1.0)\
	.set_trans(Tween.TransitionType.TRANS_LINEAR).set_ease(Tween.EaseType.EASE_OUT_IN)

	await tween.finished
	if to_item != null:
		if to_item.global_position == from_item.global_position:
			# убираем из списка целей текущую которую поразили
			processed_aims.erase(to_item)
			send_done.emit()
	else:
		call_deferred("start", from_item)
