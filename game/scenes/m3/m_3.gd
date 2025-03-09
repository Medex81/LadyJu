extends Node2D

class_name M3

enum EEvent{NO_HINT}

const group_name:String = "m3_scene"
const events_fn:String = "events"

@export var _base_m3_layer:BaseM3Layer = null

func events(event:EEvent):
	match event:
		EEvent.NO_HINT:
			if _base_m3_layer != null:
				_base_m3_layer.layer_completed(false)

			
