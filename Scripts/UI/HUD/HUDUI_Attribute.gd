extends Control
class_name HUDUI_Attribute

@export_category("Owner")
@export var owner_hud: HUDUI

@export_category("Attribute")
@export var AttributeName: StringName = &"Experience"
@export var UseControllerAttributeSet: bool = true
@export var TargetLabel: Control

@export_category("Animations")
@export var animation_player: AnimationPlayer
@export var change_animation_name: StringName = &"Changed"

func _ready() -> void:
	
	assert(owner_hud)
	assert(owner_hud.owner_player_controller)
	
	if UseControllerAttributeSet:
		
		var OwnerAS := AttributeSet.try_get_from(owner_hud.owner_player_controller)
		OwnerAttributeData = OwnerAS.get_or_init_attribute(AttributeName) if OwnerAS else null
		assert(OwnerAttributeData)
	else:
		owner_hud.owner_player_controller.controlled_pawn_changed.connect(OnOwnerPawnChanged)
		OnOwnerPawnChanged()

var OwnerAttributeData: AttributeSet.AttributeData:
	set(InData):
		
		if is_instance_valid(OwnerAttributeData):
			OwnerAttributeData.current_value_changed.disconnect(OnOwnerCurrentValueChanged)
		
		OwnerAttributeData = InData
		
		if is_instance_valid(OwnerAttributeData):
			OwnerAttributeData.current_value_changed.connect(OnOwnerCurrentValueChanged)
		
		Update()

func OnOwnerPawnChanged() -> void:
	
	var new_pawn := owner_hud.owner_player_controller.controlled_pawn
	if is_instance_valid(new_pawn) and not new_pawn.is_node_ready():
		await new_pawn.ready
	
	var OwnerAS := AttributeSet.try_get_from(new_pawn)
	OwnerAttributeData = OwnerAS.get_or_init_attribute(AttributeName) if OwnerAS else null

func OnOwnerCurrentValueChanged(in_old_value: float, in_new_value: float) -> void:
	Update()

func Update() -> void:
	
	if OwnerAttributeData:
		
		if TargetLabel is VHSLabel:
			TargetLabel.label_text = String.num_int64(OwnerAttributeData.current_value)
		elif TargetLabel is Label:
			TargetLabel.text = String.num_int64(OwnerAttributeData.current_value)
		
		visible = true
		
		if animation_player:
			animation_player.stop()
			animation_player.play(change_animation_name)
	else:
		visible = false
