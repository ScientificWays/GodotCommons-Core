@tool
extends AnimatedSprite2D
class_name Pawn2D_Sprite

static func try_get_from(in_node: Node) -> Pawn2D_Sprite:
	return ModularGlobals.try_get_from(in_node, Pawn2D_Sprite)

@export_category("Owner")
@export var owner_pawn: Pawn2D
@export var status_effect_particles_radius: float = 16.0

@export_category("Transforms")
@export var flip_transform_targets: Array[Node2D]
@export var z_index_offset: int = 0
@export var allow_different_z_index: bool = false

var particles_pivot: ParticlesPivot

var status_effect_modulate_array: Array[Color] = []

func _ready() -> void:
	
	if Engine.is_editor_hint():
		set_process(false)
		if not owner_pawn:
			owner_pawn = get_parent() as Pawn2D
		if not allow_different_z_index:
			z_index = GameGlobals_Class.PAWN_2D_SPRITE_DEFAULT_Z_INDEX + z_index_offset
			z_as_relative = false
	else:
		assert(owner_pawn)
		
		owner_pawn.body_direction_changed.connect(_handle_body_direction_changed)
		owner_pawn.died.connect(_on_owner_pawn_died)
		
		particles_pivot = ParticlesPivot.new()
		add_child(particles_pivot)
		
		scale *= owner_pawn.get_size_scale()

func _enter_tree() -> void:
	if not Engine.is_editor_hint(): ModularGlobals.init_modular_node(self)

func _exit_tree() -> void:
	if not Engine.is_editor_hint(): ModularGlobals.deinit_modular_node(self)

func _process(in_delta: float) -> void:
	pass

##
## Transforms
##
func _handle_body_direction_changed() -> void:
	
	if owner_pawn.body_direction.x > 0.0:
		flip_h = false
	elif owner_pawn.body_direction.x < 0.0:
		flip_h = true
	
	for sample_target: Node2D in flip_transform_targets:
		
		if flip_h:
			sample_target.position.x = -absf(sample_target.position.x)
		else:
			sample_target.position.x = absf(sample_target.position.x)

##
## Animations
##
func try_play_death_animation() -> bool:
	#if animation_data.use_death_animation:
	#	play(animation_data.get_death_animation_name(self))
	#	return true
	return false

func _on_owner_pawn_died(in_immediately: bool) -> void:
	if not in_immediately:
		try_remove_with_animation()

##
## Remove
##
func try_remove_with_animation(in_custom_animation_name: StringName = StringName()) -> bool:
	
	if in_custom_animation_name:
		play(in_custom_animation_name)
	else:
		if not try_play_death_animation():
			return false
	
	reparent(WorldGlobals._level._y_sorted)
	animation_finished.connect(handle_remove, Object.CONNECT_ONE_SHOT)
	return true

func handle_remove():
	particles_pivot.detach_and_remove_all()
	queue_free()
