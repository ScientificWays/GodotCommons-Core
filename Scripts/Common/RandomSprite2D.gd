extends Sprite2D

func _ready() -> void:
	frame = randi_range(0, hframes * vframes - 1)
