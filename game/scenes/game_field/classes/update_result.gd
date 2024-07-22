extends Node

class_name UpdateResult

var moves:Array
var creates:Array[int]
var deletes:Array[int]
		
func clear():
	moves.clear()
	creates.clear()
	deletes.clear()
