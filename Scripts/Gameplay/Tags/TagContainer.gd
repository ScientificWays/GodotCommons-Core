extends Node
class_name TagContainer

@export_category("Tags")
@export var _current_tags_num: Dictionary[StringName, int]

func _ready() -> void:
	pass

func get_tags_num(in_tag: StringName) -> int:
	return _current_tags_num.get(in_tag, 0)

func has_tag(in_tag: StringName) -> bool:
	return _current_tags_num.has(in_tag)

func has_all_tags(in_tags: Array[StringName]) -> bool:
	return in_tags.all(has_tag)

func has_any_tag(in_tags: Array[StringName]) -> bool:
	return in_tags.any(has_tag)

func apply_tags(in_tags: Array[StringName]) -> void:
	
	for sample_tag: StringName in in_tags:
		
		if _current_tags_num.has(sample_tag):
			_current_tags_num[sample_tag] += 1
		else:
			_current_tags_num[sample_tag] = 1

func remove_tags(in_tags: Array[StringName]) -> void:
	
	for sample_tag: StringName in in_tags:
		
		assert(_current_tags_num.has(sample_tag))
		assert(_current_tags_num[sample_tag] > 0)
		_current_tags_num[sample_tag] -= 1
		
		if _current_tags_num[sample_tag] == 0:
			_current_tags_num.erase(sample_tag)
