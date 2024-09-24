extends GridContainer

class_name Match3Grid

func _ready():
	if M3Core.init_cells(get_children(), columns) == 0:
		print("Error! Cells was not imported.")
		
#func _unhandled_input(event):
	#if event is InputEventKey and event.is_pressed():
		#call_deferred("_update")
