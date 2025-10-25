@tool
extends Control
class_name HUDUI_Healthbar

@export_category("Bar")
@export var range: Range
@export var range_control: Control
@export var ratio_lerp_speed: float = 10.0

@export_category("Image")
@export var image: TextureRect

@export_category("Animations")
@export var animation_player: AnimationPlayer
@export var receive_damage_animation_name: StringName = &"receive_damage"
@export var defeated_animation_name: StringName = &"defeated"
@export var remove_after_defeat: bool = true

@export var animated_size_mul: float = 1.0:
	set(in_mul):
		animated_size_mul = in_mul
		
		custom_minimum_size.x = 100.0 + 400.0 * animated_size_mul * target_health_bar_size_mul
		if range_control:
			range_control.custom_minimum_size.y = 16.0 * animated_size_mul
		if image:
			image.custom_minimum_size = Vector2(64.0, 64.0) * animated_size_mul * target_image_size_mul

var target_pawn: Pawn2D
var target_damage_receiver: DamageReceiver

var target_health_bar_size_mul: float = 1.0
var target_image_size_mul: float = 1.0
var target_ratio: float = 1.0

func _ready() -> void:
	
	if Engine.is_editor_hint():
		
		set_process(false)
		
		if not range:
			range = find_child("*ealth*ar*")
		if not range_control and range:
			range_control = range.get_parent()
		if not image:
			image = find_child("*mage*")
		if not animation_player:
			animation_player = find_child("*nimation*layer*")
	else:
		assert(animation_player)
		assert(range)
		assert(image)
		
		assert(target_pawn)
		
		target_health_bar_size_mul = target_pawn.health_bar_size_mul
		target_image_size_mul = target_pawn.get_image_size_scale()
		
		animated_size_mul = animated_size_mul
		
		image.texture = target_pawn.display_data.get_image()
		image.material = ResourceGlobals.GetOrCreateOutlineMaterial(target_pawn.display_data.outline_color)
		
		target_damage_receiver = DamageReceiver.try_get_from(target_pawn)
		assert(target_damage_receiver)
		
		target_damage_receiver.receive_damage.connect(_on_target_pawn_receive_damage)
		_update_target_ratio()
		
		if target_pawn.is_alive:
			target_pawn.died.connect(_on_target_pawn_died)
		else:
			handle_target_pawn_defeated()

func _process(in_delta: float) -> void:
	
	if is_equal_approx(range.ratio, target_ratio):
		range.ratio = target_ratio
		set_process(false)
	else:
		range.ratio = lerpf(range.ratio, target_ratio, ratio_lerp_speed * in_delta)

func _update_target_ratio() -> void:
	target_ratio = target_damage_receiver.get_health_fraction()
	set_process(true)

func _on_target_pawn_receive_damage(in_source: Node, in_damage: float, in_ignored_immunity_time: bool) -> void:
	handle_target_pawn_receive_damage()

func handle_target_pawn_receive_damage() -> void:
	
	if not animation_player.current_animation == defeated_animation_name:
		animation_player.play(receive_damage_animation_name)
	_update_target_ratio()

func _on_target_pawn_died(in_immediately: bool) -> void:
	handle_target_pawn_defeated()

func handle_target_pawn_defeated() -> void:
	
	animation_player.play(defeated_animation_name)
	_update_target_ratio()
	
	await animation_player.animation_finished
	
	if remove_after_defeat:
		queue_free()
