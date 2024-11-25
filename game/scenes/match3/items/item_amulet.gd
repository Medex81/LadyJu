extends Item

class_name AmuletItem

@export var projectile_path:String
@export var tex:Texture2D
var proj_scene:PackedScene = null

func _ready():
	if not projectile_path.is_empty():
		proj_scene = load(projectile_path)

func hints():
	pass

func hint_stop():
	pass
	
func is_component_running()->bool:
	var node = Components.get_component(self, c_move)
	return node and node.is_running()
	
func move(to_position:Vector2):
	var node_move = Components.get_component(self, c_move)
	if node_move:
		node_move.exec(to_position)
		
func delete():
	M3Core.add_event()
	$AnimationPlayer.play("explosion")
	await $AnimationPlayer.animation_finished
	M3Core.done_event()
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	queue_free()
	
func emit_trails(position_glob:Vector2):
	if proj_scene:
		var projectile = proj_scene.instantiate()
		if projectile:
			#var line:Line2D = Line2D.new()
			#add_child(line)
			#line.texture = tex
			#line.texture_mode = Line2D.LINE_TEXTURE_TILE
			#line.points = [position, position_glob - global_position]
			get_parent().add_child(projectile)
			var tween = get_parent().create_tween()
			tween.tween_property(projectile, "position", position_glob - global_position,  1.0)
			tween.tween_callback(func():projectile.queue_free())
