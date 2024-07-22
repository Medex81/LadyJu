extends Node

class_name UpdateResult

var moves:Array
var spawns:Array
var deletes:Array[int]
		
func clear():
	moves.clear()
	spawns.clear()
	deletes.clear()
