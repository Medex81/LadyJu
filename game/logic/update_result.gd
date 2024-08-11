extends Node

class_name UpdateResult

var moves:Array
var spawns:Array
var deletes:Array[int]
		
func clear():
	moves.clear()
	spawns.clear()
	deletes.clear()
	
	
func event_count()->int:
	return deletes.size() + moves.size() * 2 + spawns.size()
	
func is_empty()->bool:
	return true if moves.is_empty() and spawns.is_empty() and deletes.is_empty() else false
