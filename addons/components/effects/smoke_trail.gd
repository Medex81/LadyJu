extends Line2D

@export var limited_lifetime:bool = false
@export var wildness = 3.0
@export var min_spawn_distance = 5.0
@export var max_ponts = 50
@export var is_autostart:bool = false

var gravity = Vector2.UP
var lifetime = [1.0, 2.0]
var tick_speed = 0.05
var tick = 0.0
var wild_speed = 0.1
var point_age = [0.0]


func _ready():
	clear_points()
	if limited_lifetime:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, randfn(lifetime[0], lifetime[1]))
		tween.set_trans(Tween.TRANS_CIRC)
		tween.set_ease(Tween.EASE_OUT)
		
func _process(delta):
	if tick > tick_speed:
		tick = 0
		if is_autostart:
			addd_point(position + get_parent().position)
		
		for p in range(get_point_count()):
			point_age[p] += 5 * delta 
			var rand_vector = Vector2(randf_range(-wild_speed, wild_speed), randf_range(-wild_speed, wild_speed))
			points[p] += gravity + (rand_vector * wildness * point_age[p])
	else:
		tick += delta
		
func addd_point(point_pos:Vector2, at_pos = -1):
	if get_point_count() > 0 and point_pos.distance_to(points[get_point_count() - 1]) < min_spawn_distance:
		return
	if max_ponts < get_point_count():
		point_age.pop_front()
		points = points.slice(1)
		
	point_age.append(0.0)
	super.add_point(point_pos, at_pos)
	print("position ", point_pos)
