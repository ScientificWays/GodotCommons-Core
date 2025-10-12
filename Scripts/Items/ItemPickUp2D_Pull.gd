extends Area2D
class_name ItemPickUp2D_Pull

@export_category("Owner")
@export var _owner: ItemPickUp2D

@export_category("Physics")
@export var pull_force: float = 64.0
@export var pull_material: PhysicsMaterial = preload("res://addons/GodotCommons-Core/Assets/Items/PullItemMaterial.tres")

var pre_pull_material: PhysicsMaterial

func _ready() -> void:
	
	assert(_owner)
	
	body_entered.connect(_on_target_entered)
	body_exited.connect(_on_target_exited)

func _on_target_entered(in_target: Node) -> void:
	
	if _owner.optional_pick_up_area:
		_owner.add_collision_exception_with(in_target)
	
	pre_pull_material = _owner.physics_material_override
	_owner.physics_material_override = pull_material
	#_owner.sleeping = false

func _on_target_exited(in_target: Node) -> void:
	
	if _owner.optional_pick_up_area:
		_owner.remove_collision_exception_with(in_target)
	
	_owner.physics_material_override = pre_pull_material
	pre_pull_material = null

func _physics_process(InDelta: float) -> void:
	
	var targets := get_overlapping_areas() + get_overlapping_bodies()
	for sample_target: Node2D in targets:
		
		if _owner.can_pick_up(sample_target):
			var pull_direction := global_position.direction_to(sample_target.global_position)
			_owner.apply_central_force(pull_direction * pull_force)
