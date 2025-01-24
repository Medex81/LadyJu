# Компонент хитбокс отвечает за получение урона. Урон получает если сопротивляемость наносящего выше 
# или равна сопротивляемости хитбокса на указанное количество хитпоинтов. Если количество хитпоинтов
# ноль или ниже отправляем сигнал завершения жизненного цикла.

extends Area2D

class_name HitboxComponent

@export var resistance:int = 1
@export var hitpoints:int = 1

var is_dead:bool = false

signal send_end()

func hit(damage:int, _resistance:int)->bool:
	if not is_dead and resistance <= _resistance:
		hitpoints -= damage
		if hitpoints <= 0:
			is_dead = true
			send_end.emit()
		return true
	return false
