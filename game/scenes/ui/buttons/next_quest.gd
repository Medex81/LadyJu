# Запускаем следующий квест помеченный как - текущий
extends Button

@export var location:Location = null

func _on_pressed() -> void:
	if location and location.run_quest:
		location.run_quest.run()

	
