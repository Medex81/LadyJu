# Компонент хитбокс отвечает за получение урона. Урон получает если сопротивляемость наносящего выше 
# или равна сопротивляемости хитбокса на указанное количество хитпоинтов. Если количество хитпоинтов
# ноль или ниже отправляем сигнал завершения жизненного цикла.

extends Area2D

class_name HitboxComponent

@export var resistance:int = 1
@export var hitpoints:int = 1

var is_dead:bool = false

const total_damage = -1
const no_resist = -1

signal send_end()

func hit(damage:int = total_damage, _resistance:int = no_resist)->bool:
	if not is_dead and resistance <= _resistance:
		hitpoints -= damage
		if hitpoints <= 0:
			is_dead = true
			send_end.emit()
		return true
	return false
