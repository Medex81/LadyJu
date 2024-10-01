class_name Components
extends Node

@export var loop_count = 1
@export var switch_off:bool = false

signal send_start(component:String)
signal send_end(component:String)

static func get_component(customer:Node, node_name)->Components:
	if customer:
		var component = customer.get_node_or_null(node_name)
		if component and component is Components:
			return component
		print("Error. Object {0} dont have component {1}".format([customer.name, node_name]))
	return null
