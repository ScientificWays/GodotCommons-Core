extends Node
class_name PlayerController

const PlayerControllerMeta: StringName = &"PlayerController"

static func TryGetFrom(InNode: Node) -> PlayerController:
	return InNode.get_meta(PlayerControllerMeta) if is_instance_valid(InNode) and InNode.has_meta(PlayerControllerMeta) else null

@export var _Camera: PlayerCamera2D
@export var DefaultPawnScene: PackedScene

var _UniqueName: String = "zana"

func _ready() -> void:
	
	assert(_Camera)
	assert(DefaultPawnScene)
	

func _process(InDelta: float) -> void:
	ProcessMovementInputs(InDelta)

func _enter_tree() -> void:
	PlayerGlobals.PlayerArray.append(self)

func _exit_tree() -> void:
	PlayerGlobals.PlayerArray.erase(self)

##
## Pawn
##
var ControlledPawn: Pawn2D

func Respawn() -> void:
	
	var _Level := WorldGlobals._Level as LevelBase2D
	var RespawnPosition := _Level.GetPlayerSpawnPosition(self)
	
	ControlledPawn = DefaultPawnScene.instantiate()
	ControlledPawn.position = RespawnPosition
	_Level.add_child.call_deferred(ControlledPawn)
	
	ControlledPawn._Controller = self

##
## Inputs
##
var DisableMovementInputs: bool = false
var DisableTapInputs: bool = false

var MovementInput: Vector2

func ProcessMovementInputs(InDelta: float) -> void:
	
	if DisableMovementInputs or _Camera.ShouldBlockMovementInputs():
		MovementInput = Vector2.ZERO
	else:
		MovementInput = Input.get_vector(&"Left", &"Right", &"Up", &"Down")

func _unhandled_input(InEvent: InputEvent):
	
	if InEvent is InputEventScreenTouch:
		if DisableTapInputs or _Camera.ShouldBlockTapInputs():
			pass
		else:
			HandleTapInput(InEvent.position, InEvent.is_released())
	elif InEvent.is_action_pressed(&"1"):
		HandleNumberInput(1)
	elif InEvent.is_action_pressed(&"2"):
		HandleNumberInput(2)
	elif InEvent.is_action_pressed(&"3"):
		HandleNumberInput(3)
	elif InEvent.is_action_pressed(&"LeaveBarrel"):
		HandleLeaveBarrelInput()

var TapInputCallableArray: Array[Callable] = []

func HandleTapInput(InScreenPosition: Vector2, InReleased: bool):
	
	var GlobalPosition := get_viewport().get_canvas_transform().affine_inverse() * InScreenPosition
	#DamageNumberUI.Spawn(GlobalPosition + Vector2(randf_range(-10.0, 10.0), 0.0), 1)
	
	if GameGlobals.CallAllCancellable(TapInputCallableArray, [ self, GlobalPosition, InReleased ]):
		pass
	elif is_instance_valid(ControlledPawn):
		ControlledPawn.ControllerTapInput.emit(InScreenPosition, GlobalPosition, InReleased)

func HandleNumberInput(InNumber: int):
	#_Inventory.TryUseActiveArtifactByIndex(InNumber - 1)
	pass

func HandleLeaveBarrelInput():
	pass
