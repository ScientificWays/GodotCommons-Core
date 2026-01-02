extends AnimStateTransitionCondition

func _condition() -> bool:
	var body := get_body()
	return body.is_on_floor()
