extends Control
class_name HUDUI_Item

@export_category("Owner")
@export var OwnerHUD: HUDUI

@export_category("Item")
@export var container_script: Script
@export var item_data: ItemData
@export var num_label: Control

@export_category("Animations")
@export var hide_on_zero_num: bool = false
@export var animation_player: AnimationPlayer
@export var added_animation_name: StringName = &"added"
@export var removed_animation_name: StringName = &"removed"

var target_container: ItemContainer

func _ready() -> void:
	
	assert(OwnerHUD)
	assert(OwnerHUD.OwnerPlayerController)
	
	target_container = ModularGlobals.try_get_from(OwnerHUD.OwnerPlayerController, container_script)
	assert(target_container)
	
	target_container.item_added.connect(_on_container_item_added)
	target_container.item_removed.connect(_on_container_item_removed)
	_update_state()

func _on_container_item_added(in_item_data: ItemData, in_added_num: int) -> void:
	
	if in_item_data == item_data:
		_update_state()
	
	if animation_player:
		animation_player.stop()
		animation_player.play(added_animation_name)

func _on_container_item_removed(in_item_data: ItemData, in_removed_num: int) -> void:
	
	if in_item_data == item_data:
		_update_state()
	
	if animation_player:
		animation_player.stop()
		animation_player.play(removed_animation_name)

func _update_state() -> void:
	
	var items_num := target_container.get_items_num(item_data)
	
	if num_label is VHSLabel:
		num_label.label_text = String.num_int64(items_num)
	elif num_label is Label:
		num_label.text = String.num_int64(items_num)
	
	if hide_on_zero_num and items_num == 0:
		visible = false
	else:
		visible = true
