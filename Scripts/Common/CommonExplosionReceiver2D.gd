extends Node2D
class_name CommonExplosionReceiver2D

signal receive_explosion_impulse(in_explosion: Explosion2D, in_impulse: Vector2, in_offset: Vector2)

func Explosion2D_receive_impulse(in_explosion: Explosion2D, in_impulse: Vector2, in_offset: Vector2) -> bool:
	receive_explosion_impulse.emit(in_explosion, in_impulse, in_offset)
	return true
