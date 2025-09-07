@tool
extends Button
class_name OutlineButton

@export var _Data: OutlineButtonData:
	set(InData):
		_Data = InData
		Update()

@export var FocusVariantIndex: int = 0:
	set(InIndex):
		if _Data:
			FocusVariantIndex = GameGlobals_Class.ArrayClampIndex(_Data.FocusVariants, InIndex)
		else:
			FocusVariantIndex = 0
		Update()

@export var ExtraOverlayStyleBox: StyleBox:
	set(InStyleBox):
		ExtraOverlayStyleBox = InStyleBox
		Update()

@onready var _AnimationPlayer: AnimationPlayer = $AnimationPlayer

var ExtraOverlayPanel: Panel

func _ready():
	
	mouse_entered.connect(OnMouseEntered)
	mouse_exited.connect(OnMouseExited)
	
	#$Outline.visible = Engine.is_editor_hint()
	#$Outline.modulate.a = 0.0
	
	Update()

func Update():
	
	if is_node_ready() and _Data:
		
		add_theme_stylebox_override(&"normal", _Data.Normal)
		add_theme_stylebox_override(&"hover", _Data.Hover)
		add_theme_stylebox_override(&"pressed", _Data.Normal)
		add_theme_stylebox_override(&"disabled", _Data.Normal)
		add_theme_stylebox_override(&"focus", _Data.FocusVariants[FocusVariantIndex])
		
		$Outline.add_theme_stylebox_override(&"panel", _Data.FocusVariants[FocusVariantIndex])
		
		if is_instance_valid(ExtraOverlayStyleBox):
			
			if not is_instance_valid(ExtraOverlayPanel):
				ExtraOverlayPanel = Panel.new()
				ExtraOverlayPanel.set_anchors_preset(Control.PRESET_FULL_RECT)
				ExtraOverlayPanel.mouse_filter = Control.MOUSE_FILTER_IGNORE
				add_child(ExtraOverlayPanel)
			ExtraOverlayPanel.add_theme_stylebox_override(&"panel", ExtraOverlayStyleBox)
			
		elif ExtraOverlayPanel:
			
			if is_instance_valid(ExtraOverlayPanel):
				ExtraOverlayPanel.queue_free()
			ExtraOverlayPanel = null

func OnMouseEntered():
	_AnimationPlayer.play(&"ShowOutline")

func OnMouseExited():
	_AnimationPlayer.play(&"HideOutline")
