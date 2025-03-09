extends Control

class_name BaseM3Layer

enum EEvents{QUESTS_DONE, NO_HINTS, NO_STEPS}
const group_name:String = "game_field"
const events_fn:String = "events"

	
func events(event:EEvents):
	match event:
		EEvents.QUESTS_DONE:
			pass
		EEvents.NO_HINTS:
			pass
		EEvents.NO_STEPS:
			pass
