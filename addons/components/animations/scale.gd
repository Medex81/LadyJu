extends Animations

# масштаб анимации подсказки (+15%).
@export var animation_scale:float = 1.0
@export var offset:Vector2 = Vector2.ZERO
@export var is_return:bool = false
const _scale = "scale"
const _position = "position"

func exec():
	if _start([_scale, _position]):
		_tween = create_tween()
		_tween.set_loops(loop_count)
		_tween.tween_property(get_parent(), _scale, _props[_scale] * animation_scale, anim_time)
		_tween.parallel().tween_property(get_parent(), _position, offset * -((animation_scale - 1) / 2.0), anim_time)
		if is_return:
			_tween.tween_property(get_parent(), _scale, _props[_scale], anim_time)
			_tween.parallel().tween_property(get_parent(), _position, _props[_position], anim_time)
		_tween.tween_callback(_send_end_signal)
		return true
	return false
