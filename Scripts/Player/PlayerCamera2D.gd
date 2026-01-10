@tool
extends Camera2D
class_name PlayerCamera2D

@export_category("Owner")
@export var owner_player_controller: PlayerController

@export var TriggerLagOnPawnChanged: bool = true
@export var TriggerLagOnPawnTeleport: bool = true

@export_category("Movement")
@export var movement_zoom_mul: float = 0.9
@export var movement_zoom_velocity_threshold: float = 64.0

@export_category("Pending Zoom")
@export var DefaultPendingZoomLerpSpeed: float = 2.0
@onready var DefaultSmoothingSpeed = position_smoothing_speed

var PendingOffset: Vector2 = Vector2.ZERO
var PendingRotation: float = 0.0

var PendingZoom: Vector2 = Vector2.ONE
@onready var PendingZoomLerpSpeed: float = DefaultPendingZoomLerpSpeed

signal ReachedPendingZoom()

@export_category("Override Target")
@export var OverrideTargetBlocksMovementInputs: bool = true
@export var OverrideTargetBlocksTapInputs: bool = true

var OverrideTarget: Node2D = null

@export_category("Animations")
@export var CameraAnimationPlayer: AnimationPlayer

@export_category("Constant Bases")
var ConstantOffset: Vector2 = Vector2.ZERO
var ConstantRotation: float = 0.0

signal zoom_changed()

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not owner_player_controller:
			owner_player_controller = find_parent("*layer*")
		set_physics_process(false)
	else:
		process_mode = Node.PROCESS_MODE_ALWAYS
		
		assert(owner_player_controller)
		
		PlayerGlobals.default_camera_zoom_changed.connect(ResetZoom)
		ResetZoom()
		
		_on_viewport_size_changed()
		
		owner_player_controller.controlled_pawn_changed.connect(_on_owner_controlled_pawn_changed)
		_on_owner_controlled_pawn_changed()
		
		owner_player_controller.ControlledPawnTeleport.connect(OnOwnerControlledPawnTeleport)
		OnOwnerControlledPawnTeleport(true)

func _enter_tree() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _exit_tree() -> void:
	get_viewport().size_changed.disconnect(_on_viewport_size_changed)

func _physics_process(in_delta: float) -> void:
	
	offset = ConstantOffset + PendingOffset
	global_rotation = ConstantRotation + PendingRotation
	
	PendingOffset = Vector2.ZERO
	PendingRotation = 0.0
	
	if is_instance_valid(OverrideTarget):
		global_position = OverrideTarget.global_position
	elif is_instance_valid(owner_player_controller.controlled_pawn):
		global_position = owner_player_controller.controlled_pawn.global_position
	
	var FinalZoom := PendingZoom * GetMovementZoomMul()
	
	if not HasReachedZoom(FinalZoom):
		zoom = zoom.lerp(FinalZoom, PendingZoomLerpSpeed * in_delta)
		if HasReachedZoom(FinalZoom):
			zoom = FinalZoom
		zoom_changed.emit()

func _on_viewport_size_changed() -> void:
	
	if not is_node_ready():
		pass
	

func _on_owner_controlled_pawn_changed() -> void:
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
func SetSmoothingSpeed(in_speed: float) -> void:
	position_smoothing_speed = in_speed

func ResetSmoothingSpeed() -> void:
	SetSmoothingSpeed(DefaultSmoothingSpeed)

func TriggerLag(InDurationMul: float = 1.0) -> void:
	CameraAnimationPlayer.play(&"Lag", -1.0, 1.0 / InDurationMul)
	CameraAnimationPlayer.advance(0.0)

##
## Zoom
##
func HasReachedZoom(InZoom: Vector2) -> bool:
	return absf(InZoom.x - zoom.x) < 0.01 or absf(InZoom.y - zoom.y) < 0.01

func SetPendingZoomLerpSpeed(in_speed: float) -> void:
	PendingZoomLerpSpeed = in_speed

func ResetPendingZoomLerpSpeed() -> void:
	SetPendingZoomLerpSpeed(DefaultPendingZoomLerpSpeed)

func SetZoom(InZoom: float) -> void:
	PendingZoom = Vector2(InZoom, InZoom)

func ResetZoom() -> void:
	PendingZoom = Vector2(PlayerGlobals.default_camera_zoom, PlayerGlobals.default_camera_zoom)

func GetMovementZoomMul() -> float:
	
	if owner_player_controller.GetControlledPawnLinearVelocity().length() > movement_zoom_velocity_threshold \
	and not owner_player_controller.movement_input.is_zero_approx():
		return movement_zoom_mul
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
	limit_smoothed = in_smoothed
	
	limit_right = in_center.x + in_extents.x
	limit_left = in_center.x - in_extents.x
	limit_top = in_center.y - in_extents.y
	limit_bottom = in_center.y + in_extents.y
	
	TriggerLag()

func reset_camera_limits() -> void:
	limit_enabled = false
	limit_smoothed = false
