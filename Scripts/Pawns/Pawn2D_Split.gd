@tool
extends Node
class_name Pawn2D_Split

const splits_num_override_meta: StringName = &"Pawn2D_Split_splits_num_override"

static func try_get_from(in_node: Node) -> Pawn2D_Split:
	return ModularGlobals.try_get_from(in_node, Pawn2D_Split)

@export_category("Owner")
@export var owner_pawn: Pawn2D
@export var owner_sprite: Pawn2D_Sprite
@export var owner_attribute_set: AttributeSet
@export var owner_damage_receiver: DamageReceiver

@export_category("Split")
@export var health_fraction_threshold: float = 0.4
@export var split_animation_name: StringName = &"Split"
@export var split_delay: float = 0.0
@export var splits_num: int = 1

@export_category("Pawns")
@export var pawns_scene_path: String
@export var pawns_num: int = 2
@export var pawns_size_mul: float = 0.7
@export var pawns_health_mul: float = 0.8
@export var pawns_spawn_distance: float = 8.0
@export var pawns_launch_magnitude: float = 128.0

var is_splitting: bool = false

func _ready() -> void:
	
	if Engine.is_editor_hint():
		
		if not owner_pawn:
			owner_pawn = get_parent() as Pawn2D
		
		if owner_pawn:
			if not owner_sprite:
				owner_sprite = owner_pawn.find_child("*prite*")
			if not owner_attribute_set:
				owner_attribute_set = owner_pawn.find_child("*ttribute*")
			if not owner_damage_receiver:
				owner_damage_receiver = owner_pawn.find_child("*amage*eceiver")
			if pawns_scene_path.is_empty():
				pawns_scene_path = owner_pawn.scene_file_path
	else:
		splits_num = owner_pawn.get_meta(splits_num_override_meta, splits_num)
		
		if splits_num > 0:
			
			assert(owner_pawn)
			assert(owner_attribute_set)
			
			var health_data := owner_attribute_set.get_or_init_attribute(AttributeSet.Health)
			health_data.current_value_changed.connect(_on_owner_health_changed)
			
			var max_health_data := owner_attribute_set.get_or_init_attribute(AttributeSet.MaxHealth)
			max_health_data.current_value_changed.connect(_on_owner_max_health_changed)
			
			owner_pawn.add_override_level_music_delay = maxf(owner_pawn.remove_override_level_music_delay, 1.5)
			owner_pawn.remove_override_level_music_delay = maxf(owner_pawn.remove_override_level_music_delay, 2.0)
		else:
			queue_free()

func _enter_tree():
	if not Engine.is_editor_hint():
		ModularGlobals.init_modular_node(self)

func _exit_tree():
	if not Engine.is_editor_hint():
		ModularGlobals.deinit_modular_node(self)

func _on_owner_health_changed(in_old_value: float, in_new_value: float) -> void:
	try_split()

func _on_owner_max_health_changed(in_old_value: float, in_new_value: float) -> void:
	try_split()

func try_split() -> bool:
	
	if is_splitting:
		return false
	
	var fraction := owner_damage_receiver.get_health_fraction()
	if fraction < 0.0 or fraction > health_fraction_threshold:
		return false
	
	is_splitting = true
	
	var base_angle := PI * randf()
	var angle_step := PI / float(pawns_num)
	
	var pawns_scene := ResourceLoader.load(pawns_scene_path) as PackedScene
	var pawns_attachment := owner_pawn.get_parent()
	
	for sample_index: int in range(pawns_num):
		
		var spawn_direction := Vector2.from_angle(base_angle + angle_step * sample_index)
		
		var new_pawn := pawns_scene.instantiate() as Pawn2D
		new_pawn.position = owner_pawn.position + spawn_direction * pawns_spawn_distance
		new_pawn.size_scale = (owner_pawn.size_scale * pawns_size_mul)
		new_pawn.size_scale_image = (owner_pawn.size_scale_image * sqrt(pawns_size_mul))
		new_pawn.max_health = (owner_pawn.max_health * pawns_health_mul)
		new_pawn.health_bar_size_mul = (owner_pawn.health_bar_size_mul * pawns_health_mul)
		new_pawn.set_meta(splits_num_override_meta, splits_num - 1)
		
		new_pawn.ready.connect(_init_pawn_post_ready.bind(new_pawn, spawn_direction), Object.CONNECT_ONE_SHOT)
		
		if split_delay > 0.0:
			GameGlobals.spawn_one_shot_timer_for(pawns_attachment, pawns_attachment.add_child.bind(new_pawn), split_delay)
		else:
			pawns_attachment.add_child.call_deferred(new_pawn)
	
	if split_delay > 0.0:
		owner_sprite.try_remove_with_animation(split_animation_name)
	
	owner_pawn.kill(split_delay > 0.0)
	return true

func _init_pawn_post_ready(in_pawn: Pawn2D, in_spawn_direction: Vector2) -> void:
	if in_pawn.character_movement:
		in_pawn.character_movement.launch(in_spawn_direction * pawns_launch_magnitude)
