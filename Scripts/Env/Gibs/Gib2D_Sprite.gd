extends Sprite2D
class_name Gib2D_Sprite

func _ready() -> void:
	frame = randi_range(0, hframes * vframes - 1)
