extends RigidBody2D
class_name ItemPickUp2D

@export_category("Data")
@export var item_data: ItemData

@export_category("Pick Up")
@export var remove_on_pick_up: bool = true
@export var pick_up_animation_player: AnimationPlayer
@export var pick_up_animation_name: StringName = &"PickUp"
@export var optional_pick_up_area: Area2D

@export_category("Sprite")
@export var sprite_texture_per_skin_overrides: Dictionary = {}

@export_category("Explosions")
@export var explosion_impulse_mul: float = 0.12

signal pick_up_begin(in_target: Node)
signal pick_up_fail(in_target: Node)
signal pick_up_success(in_target: Node)

func _ready() -> void:
	
	assert(pick_up_animation_player)
	
	if optional_pick_up_area:
		optional_pick_up_area.area_entered.connect(_on_target_entered)
		optional_pick_up_area.body_entered.connect(_on_target_entered)
	else:
		body_entered.connect(_on_target_entered)

func _on_target_entered(in_target: Node2D) -> void:
	try_pick_up(in_target)

func can_pick_up(in_target: Node) -> bool:
	return item_data.can_pick_up(in_target)

func try_pick_up(in_target: Node) -> bool:
	
	if not can_pick_up(in_target):
		return false
	
	if not optional_pick_up_area:
		add_collision_exception_with(in_target)
	
	pick_up_begin.emit(in_target)
	
	if pick_up_animation_player:
		pick_up_animation_player.play(pick_up_animation_name)
		await pick_up_animation_player.animation_finished
	
	## Something can happen during await
	if not is_instance_valid(in_target) or not can_pick_up(in_target):
		pick_up_fail.emit(in_target)
		return false
	
	item_data.handle_pick_up(in_target)
	pick_up_success.emit(in_target)
	
	if remove_on_pick_up:
		queue_free()
	return true

func Explosion2D_receive_impulse(in_explosion: Explosion2D, in_impulse: Vector2, in_offset: Vector2) -> bool:
	apply_impulse(in_impulse * explosion_impulse_mul, in_offset)
	return true
