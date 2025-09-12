extends Control
class_name HUDUI_Attribute

@export_category("Owner")
@export var OwnerHUD: HUDUI

@export_category("Attribute")
@export var AttributeName: StringName = &"Experience"
@export var TargetLabel: Label

func _ready() -> void:
	
	assert(OwnerHUD)
	
	OwnerHUD.OwnerPlayerController.ControlledPawnChanged.connect(OnOwnerPawnChanged)
	OnOwnerPawnChanged()

var OwnerAttributeData: AttributeSet.AttributeData

func OnOwnerPawnChanged() -> void:
	
	if is_instance_valid(OwnerAttributeData):
		OwnerAttributeData.CurrentValueChanged.disconnect(OnOwnerCurrentValueChanged)
	
	var NewPawn := OwnerHUD.OwnerPlayerController.ControlledPawn
	if is_instance_valid(NewPawn) and not NewPawn.is_node_ready():
		await NewPawn.ready
	
	var OwnerAS := AttributeSet.TryGetFrom(NewPawn)
	OwnerAttributeData = OwnerAS.GetOrInitAttribute(AttributeName) if OwnerAS else null
	
	if is_instance_valid(OwnerAttributeData):
		OwnerAttributeData.CurrentValueChanged.connect(OnOwnerCurrentValueChanged)
	
	Update()

func OnOwnerCurrentValueChanged(InOldValue: float, InNewValue: float) -> void:
	Update()

func Update() -> void:
	
	if OwnerAttributeData:
		TargetLabel.text = String.num_int64(OwnerAttributeData.CurrentValue)
