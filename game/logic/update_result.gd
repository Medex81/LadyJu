extends Node

class_name UpdateResult

var moves:Array
var spawns:Array
var deletes:Array[int]
		
func clear():
	moves.clear()
	spawns.clear()
	deletes.clear()
	
func is_empty()->bool:
	return true if moves.is_empty() and spawns.is_empty() and deletes.is_empty() else false
