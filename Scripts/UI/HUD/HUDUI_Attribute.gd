extends Control
class_name HUDUI_Attribute

@export_category("Owner")
@export var OwnerHUD: HUDUI

@export_category("Attribute")
@export var AttributeName: StringName = &"Experience"
@export var UseControllerAttributeSet: bool = true
@export var TargetLabel: Control

@export_category("Animations")
@export var animation_player: AnimationPlayer
@export var change_animation_name: StringName = &"Changed"

func _ready() -> void:
	
	assert(OwnerHUD)
	assert(OwnerHUD.OwnerPlayerController)
	
	if UseControllerAttributeSet:
		
		var OwnerAS := AttributeSet.TryGetFrom(OwnerHUD.OwnerPlayerController)
		OwnerAttributeData = OwnerAS.GetOrInitAttribute(AttributeName) if OwnerAS else null
		assert(OwnerAttributeData)
	else:
		OwnerHUD.OwnerPlayerController.ControlledPawnChanged.connect(OnOwnerPawnChanged)
		OnOwnerPawnChanged()

var OwnerAttributeData: AttributeSet.AttributeData:
	set(InData):
		
		if is_instance_valid(OwnerAttributeData):
			OwnerAttributeData.CurrentValueChanged.disconnect(OnOwnerCurrentValueChanged)
		
		OwnerAttributeData = InData
		
		if is_instance_valid(OwnerAttributeData):
			OwnerAttributeData.CurrentValueChanged.connect(OnOwnerCurrentValueChanged)
		
		Update()

func OnOwnerPawnChanged() -> void:
	
	var NewPawn := OwnerHUD.OwnerPlayerController.ControlledPawn
	if is_instance_valid(NewPawn) and not NewPawn.is_node_ready():
		await NewPawn.ready
	
	var OwnerAS := AttributeSet.TryGetFrom(NewPawn)
	OwnerAttributeData = OwnerAS.GetOrInitAttribute(AttributeName) if OwnerAS else null

func OnOwnerCurrentValueChanged(InOldValue: float, InNewValue: float) -> void:
	Update()

func Update() -> void:
	
	if OwnerAttributeData:
		
		if TargetLabel is VHSLabel:
			TargetLabel.label_text = String.num_int64(OwnerAttributeData.CurrentValue)
		elif TargetLabel is Label:
			TargetLabel.text = String.num_int64(OwnerAttributeData.CurrentValue)
		
		visible = true
		
		if animation_player:
			animation_player.stop()
			animation_player.play(change_animation_name)
	else:
		visible = false
