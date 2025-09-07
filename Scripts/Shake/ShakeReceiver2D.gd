extends Area2D
class_name ShakeReceiver2D

@export var _Camera: PlayerCamera2D

func GetPlayerCamera() -> PlayerCamera2D:
	return _Camera
