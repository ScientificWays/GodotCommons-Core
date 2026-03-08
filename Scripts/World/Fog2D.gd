@tool
extends Area2D
class_name Fog2D

@export_category("Particles")
@export var web_switch: WebSwitch2D

@export_category("Animations")
@export var animation_player: AnimationPlayer
@export var to_active_animation_name: StringName = &"to_active"
@export var to_cleared_animation_name: StringName = &"to_cleared"
@export var to_weak_animation_name: StringName = &"to_weak"

const STATE_ACTIVE: int = 0
const STATE_CLEARED: int = 1
const STATE_WEAK: int = 2

var desired_preprocess: float = 0.0:
	set(in_value):
		desired_preprocess = in_value
		_update_optimization()

var desired_amount: int = 8:
	set(in_value):
		desired_amount = in_value
		_update_optimization()

var to_cleared_speed_mul: float = 1.0

var current_state: int = STATE_ACTIVE:
	set(in_state):
		
		if in_state != current_state:
			
			current_state = in_state
			
			var particles := web_switch.instantiated_node
			
			match current_state:
				STATE_ACTIVE:
					animation_player.play(to_active_animation_name)
					particles.speed_scale = 1.0
					if particles.amount != desired_amount:
						particles.amount = desired_amount
				STATE_CLEARED:
					animation_player.play(to_cleared_animation_name, -1.0, to_cleared_speed_mul)
					particles.speed_scale = 6.0 * to_cleared_speed_mul
					if particles.amount != desired_amount:
						particles.amount = desired_amount
				STATE_WEAK:
					animation_player.play(to_weak_animation_name)
					particles.speed_scale = 0.6
					particles.amount = roundi(float(desired_amount) * 0.25)
					particles.restart()

func _ready() -> void:
	
	if Engine.is_editor_hint():
		
		var preview_sprite := Sprite2D.new()
		preview_sprite.texture = load("res://addons/GodotCommons-Core/Assets/Particles/Fog/Fog001.png")
		preview_sprite.hframes = 2
		preview_sprite.vframes = 2
		preview_sprite.frame = randi_range(0, 3)
		preview_sprite.modulate = Color(Color.CYAN, 0.2)
		add_child(preview_sprite)
		
		var collision := find_child("*ollision*") as CollisionShape2D
		if collision and get_parent() is TileMapLayer:
			collision.visible = false
	else:
		area_entered.connect(_on_interact_trigger_target_entered)
		body_entered.connect(_on_interact_trigger_target_entered)
		
		animation_player.animation_finished.connect(_on_animation_finished)
		
		if PlatformGlobals.is_gl_compatibility_rendering_method():
			web_switch.instantiated_node.modulate.a *= 2.0
		
		_update_optimization()
		
		current_state = STATE_ACTIVE

func Explosion2D_receive_impulse(in_explosion: Explosion2D, in_impulse: Vector2, in_offset: Vector2) -> bool:
	
	if current_state == STATE_ACTIVE:
		to_cleared_speed_mul = 5.0
		current_state = STATE_CLEARED
		return true
	return false

func _update_optimization() -> void:
	
	if not is_node_ready():
		return
	
	

func _on_interact_trigger_target_entered(in_target: Node2D) -> void:
	
	if current_state == STATE_ACTIVE:
		var target_player := PlayerController.try_get_from(in_target)
		if target_player:
			to_cleared_speed_mul = 1.0
			current_state = STATE_CLEARED

func _on_animation_finished(in_animation_name: StringName) -> void:
	if in_animation_name == to_cleared_animation_name:
		current_state = STATE_WEAK
