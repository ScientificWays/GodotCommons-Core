extends Area2D
class_name ItemPickUp2D_ShopSlot

@export_category("Components")
@export var attribute_set: AttributeSet
@export var damage_receiver: DamageReceiver

@export_category("Cost")
@export var cost_control: Control
@export var cost_label: VHSLabel

@export_category("Cage")
@export var cage_body: StaticBody2D
@export var cage_health: float = 100.0

var owner_pick_up: ItemPickUp2D

func _ready() -> void:
	
	damage_receiver.set_max_health(cage_health)
	damage_receiver.set_health(cage_health)
	damage_receiver.receive_damage_lethal.connect(_on_receive_damage_lethal)
	
	_update_cost()
	
	disable_cage()

func _enter_tree() -> void:
	
	owner_pick_up = get_parent()
	assert(owner_pick_up)
	
	cage_body.add_collision_exception_with(owner_pick_up)
	owner_pick_up.freeze_counter += 1

func _exit_tree() -> void:
	
	if is_cage_enabled():
		disable_cage()
	
	cage_body.remove_collision_exception_with(owner_pick_up)
	owner_pick_up.freeze_counter -= 1

func _update_cost() -> void:
	cost_label.label_text = String.num_int64(owner_pick_up.item_data.shop_cost)

func is_cage_enabled() -> bool:
	return cage_body.visible

func enable_cage() -> void:
	
	assert(not is_cage_enabled())
	
	cage_body.visible = true
	cage_body.process_mode = Node.PROCESS_MODE_INHERIT
	damage_receiver.ignore_damage = false
	owner_pick_up.block_pick_up_counter += 1

func disable_cage() -> void:
	
	assert(is_cage_enabled())
	
	cage_body.visible = false
	cage_body.process_mode = Node.PROCESS_MODE_DISABLED
	damage_receiver.ignore_damage = true
	owner_pick_up.block_pick_up_counter -= 1

func _on_receive_damage_lethal(in_source: Node, in_damage: float, in_ignored_immunity_time: bool) -> void:
	disable_cage()
