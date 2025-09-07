extends Camera2D
class_name PlayerCamera2D

@export_category("Owner")
@export var OwnerController: PlayerController

@export_category("Camera")
@onready var DefaultSmoothingSpeed = position_smoothing_speed
@export var DefaultPendingZoomLerpSpeed: float = 10.0

var ConstantOffset: Vector2 = Vector2.ZERO
var ConstantRotation: float = 0.0

var PendingOffset: Vector2 = Vector2.ZERO
var PendingRotation: float = 0.0

var PendingZoomType: StringName = &"Default"
var PendingZoom: Vector2 = Vector2.ONE
@onready var PendingZoomLerpSpeed: float = DefaultPendingZoomLerpSpeed

var OverrideTarget: Node2D = null
@export var OverrideTargetBlocksMovementInputs: bool = true
@export var OverrideTargetBlocksTapInputs: bool = true

signal ReachedPendingZoom()

func _ready():
	
	assert(OwnerController)
	
	ResetZoom()
	OnViewportSizeChanged()

func _enter_tree():
	PlayerGlobals.ZoomOverridesChanged.connect(UpdateObservedTileMapAreaSize)
	get_viewport().size_changed.connect(OnViewportSizeChanged)

func _exit_tree():
	PlayerGlobals.ZoomOverridesChanged.disconnect(UpdateObservedTileMapAreaSize)
	get_viewport().size_changed.disconnect(OnViewportSizeChanged)

func OnViewportSizeChanged():
	if is_node_ready():
		UpdateObservedTileMapAreaSize()

func _physics_process(InDelta: float) -> void:
	
	offset = ConstantOffset + PendingOffset
	global_rotation = ConstantRotation + PendingRotation
	
	PendingOffset = Vector2.ZERO
	PendingRotation = 0.0
	
	if is_instance_valid(OverrideTarget):
		global_position = OverrideTarget.global_position
	elif is_instance_valid(OwnerController.ControlledPawn):
		global_position = OwnerController.ControlledPawn.global_position
	
	if not HasReachedPendingZoom():
		zoom = zoom.lerp(PendingZoom, PendingZoomLerpSpeed * InDelta)
		if HasReachedPendingZoom():
			zoom = PendingZoom

func SetSmoothingSpeed(InSpeed: float):
	position_smoothing_speed = InSpeed

func ResetSmoothingSpeed():
	SetSmoothingSpeed(DefaultSmoothingSpeed)

func HasReachedPendingZoom() -> bool:
	return absf(PendingZoom.x - zoom.x) < 0.01 or absf(PendingZoom.y - zoom.y) < 0.01

func SetPendingZoomLerpSpeed(InSpeed: float):
	PendingZoomLerpSpeed = InSpeed

func ResetPendingZoomLerpSpeed():
	SetPendingZoomLerpSpeed(DefaultPendingZoomLerpSpeed)

func ResetZoom():
	PendingZoom = PlayerGlobals.GetDefaultCameraZoom()

func ShouldBlockMovementInputs() -> bool:
	return is_instance_valid(OverrideTarget) and OverrideTargetBlocksMovementInputs

func ShouldBlockTapInputs() -> bool:
	return is_instance_valid(OverrideTarget) and OverrideTargetBlocksTapInputs

##
## Tiles
##
var CurrentObservedTileMapAreaSize: Vector2i = Vector2i.ZERO

func GetObservedTileMapAreaRect(InTileMap: TileMap) -> Rect2i:
	var CameraPosition := get_screen_center_position()
	var TileMapCoords := InTileMap.local_to_map(InTileMap.to_local(CameraPosition))
	return Rect2i(TileMapCoords - CurrentObservedTileMapAreaSize / 2, CurrentObservedTileMapAreaSize)

func UpdateObservedTileMapAreaSize():
	var DefaultCameraViewportSize := Vector2(get_viewport().size) / PlayerGlobals.GetDefaultCameraZoom() as Vector2
	#CurrentObservedTileMapAreaSize = Vector2i(DefaultCameraViewportSize / Vector2(WorldGlobals._Level._LevelTileMap.tile_set.tile_size))
	#print(CurrentObservedTileMapAreaSize)

func GetCameraRect() -> Rect2:
	var OutRect := get_viewport_rect()
	OutRect.size /= zoom
	OutRect.position = get_screen_center_position() - OutRect.size * 0.5
	return OutRect
