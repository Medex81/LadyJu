extends InfoComponent

class_name MatchInfoComponent

@export var _match_type:MatcherComponent.EMatcher = MatcherComponent.EMatcher.NONE

func get_match_type()->MatcherComponent.EMatcher:
	return _match_type
