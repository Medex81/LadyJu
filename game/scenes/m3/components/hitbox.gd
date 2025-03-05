# Компонент хитбокс отвечает за получение урона. Урон получает если сопротивляемость наносящего выше 
# или равна сопротивляемости хитбокса на указанное количество хитпоинтов. Если количество хитпоинтов
# ноль или ниже отправляем сигнал завершения жизненного цикла.

extends Area2D

class_name HitboxComponent

@export var resistance:int = 1
@export var hitpoints:int = 1
@export var info_component:InfoComponent = null

func hit(damage:int, _resistance:int)->bool:
	if not info_component.is_blocked():
		if hitpoints <= 0:
			return false
		if resistance <= _resistance:
			hitpoints -= damage
			if hitpoints <= 0:
				info_component.finalize()
			return true
	return false
