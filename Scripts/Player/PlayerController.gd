extends Node
class_name PlayerController

const PlayerControllerMeta: StringName = &"PlayerController"

static func try_get_from(in_node: Node) -> PlayerController:
	return in_node.get_meta(PlayerControllerMeta) if is_instance_valid(in_node) and in_node.has_meta(PlayerControllerMeta) else null

@export_category("Camera")
@export var _camera: PlayerCamera2D

@export_category("Pawn")
@export var default_pawn_scene: PackedScene

@export_category("Inventory")
@export var default_item_containers: Array[PackedScene]

var _UniqueName: String = "zana"

func _ready() -> void:
	
	assert(_camera)
	assert(default_pawn_scene)
	

func _process(in_delta: float) -> void:
	ProcessMovementInputs(in_delta)

func _enter_tree() -> void:
	PlayerGlobals.PlayerArray.append(self)

func _exit_tree() -> void:
	PlayerGlobals.PlayerArray.erase(self)

##
## Pawn
##
var ControlledPawn: Pawn2D:
	set(InPawn):
		
		if is_instance_valid(ControlledPawn):
			ControlledPawn.tree_exited.disconnect(OnControlledPawnTreeExited)
			ControlledPawn.remove_meta(PlayerControllerMeta)
		
		ControlledPawn = InPawn
		
		if is_instance_valid(ControlledPawn):
			ControlledPawn.tree_exited.connect(OnControlledPawnTreeExited)
			ControlledPawn.set_meta(PlayerControllerMeta, self)
		
		ControlledPawnChanged.emit()

signal ControlledPawnChanged()
signal ControlledPawnTeleport(in_reset_camera: bool)

func OnControlledPawnTreeExited() -> void:
	ControlledPawn = null

func Restart() -> void:
	
	var _level := WorldGlobals._level as LevelBase2D
	var RestartPosition := _level.get_player_spawn_position(self)
	
	ControlledPawn = default_pawn_scene.instantiate()
	ControlledPawn.position = RestartPosition
	_level.add_child.call_deferred(ControlledPawn)
	
	ControlledPawn._Controller = self

func GetControlledPawnLinearVelocity() -> Vector2:
	
	if is_instance_valid(ControlledPawn):
		return PhysicsServer2D.body_get_state(ControlledPawn.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY)
	return Vector2.ZERO

##
## Inputs
##
var DisableMovementInputs: bool = false
var DisableTapInputs: bool = false

var MovementInput: Vector2

func ProcessMovementInputs(in_delta: float) -> void:
	
	if DisableMovementInputs or _camera.ShouldBlockMovementInputs():
		MovementInput = Vector2.ZERO
	else:
		MovementInput = Input.get_vector(&"Left", &"Right", &"Up", &"Down")

func _unhandled_input(InEvent: InputEvent) -> void:
	
	if InEvent is InputEventScreenTouch:
		
		if DisableTapInputs or _camera.ShouldBlockTapInputs():
			pass
		else:
			HandleTapInput(InEvent.position, InEvent.is_released())
		get_viewport().set_input_as_handled()
		
	elif InEvent.is_action_pressed(&"1"):
		HandleNumberInput(1)
		get_viewport().set_input_as_handled()
		
	elif InEvent.is_action_pressed(&"2"):
		HandleNumberInput(2)
		get_viewport().set_input_as_handled()
		
	elif InEvent.is_action_pressed(&"3"):
		HandleNumberInput(3)
		get_viewport().set_input_as_handled()
		
	elif InEvent.is_action_pressed(&"LeaveBarrel"):
		HandleLeaveBarrelInput()
		get_viewport().set_input_as_handled()
		

var TapInputCallableArray: Array[Callable] = []

signal TapInputHandled(InScreenPosition: Vector2, InGlobalPosition: Vector2, InReleased: bool, InConsumedByPawn: bool)

func HandleTapInput(InScreenPosition: Vector2, InReleased: bool) -> void:
	
	var GlobalPosition := get_viewport().get_canvas_transform().affine_inverse() * InScreenPosition
	#DamageNumberUI.spawn(GlobalPosition + Vector2(randf_range(-10.0, 10.0), 0.0), 1)
	
	var ConsumedByPawn := false
	if GameGlobals.CallAllCancellable(TapInputCallableArray, [ self, GlobalPosition, InReleased ]):
		pass
	elif is_instance_valid(ControlledPawn):
		ControlledPawn.ControllerTapInput.emit(InScreenPosition, GlobalPosition, InReleased)
		ConsumedByPawn = true
	
	TapInputHandled.emit(InScreenPosition, GlobalPosition, InReleased, ConsumedByPawn)

func HandleNumberInput(InNumber: int) -> void:
	#_Inventory.TryUseActiveArtifactByIndex(InNumber - 1)
	pass

func HandleLeaveBarrelInput() -> void:
	pass
