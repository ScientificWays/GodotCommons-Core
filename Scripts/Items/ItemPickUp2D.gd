@tool
extends RigidBody2D
class_name ItemPickUp2D

@export_category("Data")
@export var item_data: ItemData

@export_category("Pick Up")
@export var pick_up_add_num: int = 1
@export var remove_on_pick_up: bool = true
@export var pick_up_animation_player: AnimationPlayer
@export var pick_up_animation_name: StringName = &"PickUp"
@export var optional_pick_up_area: Area2D

@export_category("Sprite")
@export var sprite: Sprite2D
@export var sprite_texture_per_skin_overrides: Dictionary = {}
@export var allow_different_sprite_z_index: bool = false

@export_category("Explosions")
@export var explosion_impulse_mul: float = 0.12

var block_pick_up_counter: int = 0
var freeze_counter: int = 0:
	set(in_counter):
		freeze_counter = in_counter
		freeze = (freeze_counter > 0)

signal pick_up_begin(in_target: Node)
signal pick_up_fail(in_target: Node)
signal pick_up_success(in_target: Node)

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not sprite:
			sprite = find_child("*?prite*")
		if sprite and not allow_different_sprite_z_index:
			sprite.z_index = GameGlobals_Class.ITEM_PICK_UP_2D_SPRITE_DEFAULT_Z_INDEX
			sprite.z_as_relative = false
	else:
		
		assert(pick_up_animation_player)
		
		if optional_pick_up_area:
			optional_pick_up_area.area_entered.connect(_on_target_entered)
			optional_pick_up_area.body_entered.connect(_on_target_entered)
		else:
			body_entered.connect(_on_target_entered)

func _on_target_entered(in_target: Node2D) -> void:
	try_pick_up(in_target)

var can_pick_up_extra_checks: Array[Callable]

func can_pick_up(in_target: Node) -> bool:
	
	assert(is_node_ready())
	
	if (block_pick_up_counter > 0) or not item_data.can_pick_up(in_target, pick_up_add_num):
		return false
	
	for sample_check: Callable in can_pick_up_extra_checks:
		if not sample_check.call(in_target):
			return false
	return true

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
	
	item_data.handle_pick_up(in_target, pick_up_add_num)
	pick_up_success.emit(in_target)
	
	if remove_on_pick_up:
		queue_free()
	return true

func Explosion2D_receive_impulse(in_explosion: Explosion2D, in_impulse: Vector2, in_offset: Vector2) -> bool:
	apply_impulse(in_impulse * explosion_impulse_mul, in_offset)
	return true
