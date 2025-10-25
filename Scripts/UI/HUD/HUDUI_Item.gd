@tool
extends Control
class_name HUDUI_Item

@export_category("Owner")
@export var owner_hud: HUDUI

@export_category("Data")
@export var container_script: Script
@export var item_data: ItemData:
	set(in_data):
		item_data = in_data
		_update()

@export_category("Appearance")
@export var image: TextureRect
@export var num_label: Control
@export var hide_on_zero_num: bool = false

@export_category("Animations")
@export var animation_player: AnimationPlayer
@export var added_animation_name: StringName = &"added"
@export var removed_animation_name: StringName = &"removed"

var target_container: ItemContainer

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not owner_hud:
			owner_hud = find_parent("*HUD*")
	else:
		assert(owner_hud)
		assert(owner_hud.owner_player_controller)
		
		target_container = ModularGlobals.try_get_from(owner_hud.owner_player_controller, container_script)
		assert(target_container)
		
		target_container.item_added.connect(_on_container_item_added)
		target_container.item_removed.connect(_on_container_item_removed)
	_update()

func _on_container_item_added(in_item_data: ItemData, in_added_num: int) -> void:
	
	if in_item_data == item_data:
		_update()
	
	if animation_player:
		animation_player.stop()
		animation_player.play(added_animation_name)

func _on_container_item_removed(in_item_data: ItemData, in_removed_num: int) -> void:
	
	if in_item_data == item_data:
		_update()
	
	if animation_player:
		animation_player.stop()
		animation_player.play(removed_animation_name)

func _update() -> void:
	
	if not item_data or not is_node_ready():
		visible = false
		return
	
	if image:
		image.texture = item_data.display_data.get_image()
	
	var items_num := maxi(item_data.max_stack, 1)
	
	if not Engine.is_editor_hint():
		items_num = target_container.get_items_num(item_data)
	
	if num_label:
		if num_label is VHSLabel:
			num_label.label_text = String.num_int64(items_num)
		elif num_label is Label:
			num_label.text = String.num_int64(items_num)
	
	if hide_on_zero_num and items_num == 0:
		visible = false
	else:
		visible = true
