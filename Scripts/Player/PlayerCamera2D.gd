extends Camera2D
class_name PlayerCamera2D

@export_category("Owner")
@export var OwnerPlayerController: PlayerController
@export var TriggerLagOnPawnChanged: bool = true
@export var TriggerLagOnPawnTeleport: bool = true

@export_category("Camera")
@export var CameraAnimationPlayer: AnimationPlayer
@export var DefaultPendingZoomLerpSpeed: float = 2.0
@onready var DefaultSmoothingSpeed = position_smoothing_speed

var ConstantOffset: Vector2 = Vector2.ZERO
var ConstantRotation: float = 0.0

var PendingOffset: Vector2 = Vector2.ZERO
var PendingRotation: float = 0.0

var PendingZoom: Vector2 = Vector2.ONE
@onready var PendingZoomLerpSpeed: float = DefaultPendingZoomLerpSpeed

var OverrideTarget: Node2D = null
@export var OverrideTargetBlocksMovementInputs: bool = true
@export var OverrideTargetBlocksTapInputs: bool = true

signal ReachedPendingZoom()

func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	assert(OwnerPlayerController)
	
	PlayerGlobals.default_camera_zoom_changed.connect(ResetZoom)
	ResetZoom()
	
	OnViewportSizeChanged()
	
	OwnerPlayerController.ControlledPawnChanged.connect(OnOwnerControlledPawnChanged)
	OnOwnerControlledPawnChanged()
	
	OwnerPlayerController.ControlledPawnTeleport.connect(OnOwnerControlledPawnTeleport)
	OnOwnerControlledPawnTeleport()

func _enter_tree() -> void:
	get_viewport().size_changed.connect(OnViewportSizeChanged)

func _exit_tree() -> void:
	get_viewport().size_changed.disconnect(OnViewportSizeChanged)

func _physics_process(in_delta: float) -> void:
	
	offset = ConstantOffset + PendingOffset
	global_rotation = ConstantRotation + PendingRotation
	
	PendingOffset = Vector2.ZERO
	PendingRotation = 0.0
	
	if is_instance_valid(OverrideTarget):
		global_position = OverrideTarget.global_position
	elif is_instance_valid(OwnerPlayerController.ControlledPawn):
		global_position = OwnerPlayerController.ControlledPawn.global_position
	
	var FinalZoom := PendingZoom * GetMovementZoomMul()
	
	if not HasReachedZoom(FinalZoom):
		zoom = zoom.lerp(FinalZoom, PendingZoomLerpSpeed * in_delta)
		if HasReachedZoom(FinalZoom):
			zoom = FinalZoom

func OnViewportSizeChanged() -> void:
	
	if is_node_ready():
		pass

func OnOwnerControlledPawnChanged() -> void:
	if TriggerLagOnPawnChanged:
		TriggerLag()

func OnOwnerControlledPawnTeleport() -> void:
	if TriggerLagOnPawnTeleport:
		TriggerLag()

##
## Lag
##
func SetSmoothingSpeed(InSpeed: float) -> void:
	position_smoothing_speed = InSpeed

func ResetSmoothingSpeed() -> void:
	SetSmoothingSpeed(DefaultSmoothingSpeed)

func TriggerLag(InDurationMul: float = 1.0) -> void:
	CameraAnimationPlayer.play(&"Lag", -1.0, 1.0 / InDurationMul)

##
## Zoom
##
func HasReachedZoom(InZoom: Vector2) -> bool:
	return absf(InZoom.x - zoom.x) < 0.01 or absf(InZoom.y - zoom.y) < 0.01

func SetPendingZoomLerpSpeed(InSpeed: float) -> void:
	PendingZoomLerpSpeed = InSpeed

func ResetPendingZoomLerpSpeed() -> void:
	SetPendingZoomLerpSpeed(DefaultPendingZoomLerpSpeed)

func SetZoom(InZoom: float) -> void:
	PendingZoom = Vector2(InZoom, InZoom)

func ResetZoom() -> void:
	PendingZoom = Vector2(PlayerGlobals.default_camera_zoom, PlayerGlobals.default_camera_zoom)

func GetMovementZoomMul() -> float:
	
	if OwnerPlayerController.GetControlledPawnLinearVelocity().length() > 64.0 \
	and not OwnerPlayerController.MovementInput.is_zero_approx():
		return 0.9
	else:
		return 1.0

##
## Inputs
##
func ShouldBlockMovementInputs() -> bool:
	return is_instance_valid(OverrideTarget) and OverrideTargetBlocksMovementInputs

func ShouldBlockTapInputs() -> bool:
	return is_instance_valid(OverrideTarget) and OverrideTargetBlocksTapInputs
