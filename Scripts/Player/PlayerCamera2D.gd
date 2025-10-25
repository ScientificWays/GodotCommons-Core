@tool
extends Camera2D
class_name PlayerCamera2D

@export_category("Owner")
@export var owner_player_controller: PlayerController

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
	
	if Engine.is_editor_hint():
		if not owner_player_controller:
			owner_player_controller = find_parent("*layer*")
	else:
		process_mode = Node.PROCESS_MODE_ALWAYS
		
		assert(owner_player_controller)
		
		PlayerGlobals.default_camera_zoom_changed.connect(ResetZoom)
		ResetZoom()
		
		OnViewportSizeChanged()
		
		owner_player_controller.controlled_pawn_changed.connect(OnOwnercontrolled_pawn_changed)
		OnOwnercontrolled_pawn_changed()
		
		owner_player_controller.ControlledPawnTeleport.connect(OnOwnerControlledPawnTeleport)
		OnOwnerControlledPawnTeleport(true)

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
	elif is_instance_valid(owner_player_controller.ControlledPawn):
		global_position = owner_player_controller.ControlledPawn.global_position
	
	var FinalZoom := PendingZoom * GetMovementZoomMul()
	
	if not HasReachedZoom(FinalZoom):
		zoom = zoom.lerp(FinalZoom, PendingZoomLerpSpeed * in_delta)
		if HasReachedZoom(FinalZoom):
			zoom = FinalZoom

func OnViewportSizeChanged() -> void:
	
	if is_node_ready():
		pass

func OnOwnercontrolled_pawn_changed() -> void:
	if TriggerLagOnPawnChanged:
		TriggerLag()

func OnOwnerControlledPawnTeleport(in_reset_camera: bool) -> void:
	
	if in_reset_camera:
		reset_smoothing()
	else:
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
	
	if owner_player_controller.GetControlledPawnLinearVelocity().length() > 64.0 \
	and not owner_player_controller.MovementInput.is_zero_approx():
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

##
## Limits
##
func set_camera_limits(in_center: Vector2, in_extents: Vector2, in_smoothed: bool = true) -> void:
	
	limit_enabled = true
	
	limit_right = in_center.x + in_extents.x
	limit_left = in_center.x - in_extents.x
	limit_top = in_center.y - in_extents.y
	limit_bottom = in_center.y + in_extents.y
	
	limit_smoothed = in_smoothed
	
	TriggerLag()

func reset_camera_limits() -> void:
	limit_enabled = false
