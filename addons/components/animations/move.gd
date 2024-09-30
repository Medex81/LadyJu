extends Animations

const _position = "position"

func exec(to_position:Vector2)->bool:
	if _start([_position]):
		_tween = create_tween()
		_tween.tween_property(get_parent(), _position, to_position,  anim_time)
		_tween.tween_callback(_send_end_signal)
		return true
	return false
