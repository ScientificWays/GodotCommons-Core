extends AnimStateTransitionCondition

@export_category("Tags")
@export var tag: StringName = &""

func _condition() -> bool:
	var tags_container := get_tags_container()
	return tags_container.has_tag(tag)
