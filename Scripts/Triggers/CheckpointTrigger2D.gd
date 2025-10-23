@tool
extends Area2D
class_name CheckpointTrigger2D

@export var new_player_respawn: Node2D
@export var animation_player: AnimationPlayer:
	get():
		if not animation_player:
			return find_child("*nimation*layer*")
		return animation_player

@export var animation_name: StringName = &"trigger"

func _ready() -> void:
	area_entered.connect(_on_target_entered)
	body_entered.connect(_on_target_entered)

func _on_target_entered(in_target: Node2D) -> void:
	activate_for(in_target)

func Explosion2D_receive_impulse(in_explosion: Explosion2D, in_impulse: Vector2, in_offset: Vector2) -> bool:
	if in_explosion._instigator:
		activate_for(in_explosion._instigator)
	return true

func activate_for(in_target: Node) -> void:
	
	if animation_player:
		animation_player.play(animation_name)
	
	assert(new_player_respawn)
	WorldGlobals._level.default_player_spawn = new_player_respawn
