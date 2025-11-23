@tool
extends Node
class_name PlayerController

const PlayerControllerMeta: StringName = &"PlayerController"

static func try_get_from(in_node: Node) -> PlayerController:
	return in_node.get_meta(PlayerControllerMeta) if is_instance_valid(in_node) and in_node.has_meta(PlayerControllerMeta) else null

@export_category("Camera")
@export var _camera: PlayerCamera2D

@export_category("Pawn")
@export var default_pawn_scene_path: String

@export_category("Inventory")
@export var default_item_containers: Array[PackedScene]

var unique_name: String = "zana"

func _ready() -> void:
	
	if not ProjectSettings.get_setting_with_override("input_devices/pointing/emulate_touch_from_mouse"):
		push_warning("emulate_touch_from_mouse is not set, handle_tap_input() will not work with mouse!")
	
	if Engine.is_editor_hint():
		if not _camera:
			_camera = find_child("*?amera*")
		set_process(false)
	else:
		assert(_camera)
		assert(not get_new_pawn_scene_path().is_empty())

func _process(in_delta: float) -> void:
	ProcessMovementInputs(in_delta)

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		PlayerGlobals.player_array.append(self)

func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		PlayerGlobals.player_array.erase(self)

##
## Pawn
##
var controlled_pawn: Pawn2D:
	set(InPawn):
		
		if is_instance_valid(controlled_pawn):
			controlled_pawn.tree_exited.disconnect(_on_controlled_pawn_tree_exited)
			controlled_pawn.died.disconnect(_on_controlled_pawn_died)
			controlled_pawn.remove_meta(PlayerControllerMeta)
		
		controlled_pawn = InPawn
		
		if is_instance_valid(controlled_pawn):
			controlled_pawn.tree_exited.connect(_on_controlled_pawn_tree_exited)
			controlled_pawn.died.connect(_on_controlled_pawn_died)
			controlled_pawn.set_meta(PlayerControllerMeta, self)
		
		controlled_pawn_changed.emit()

signal controlled_pawn_changed()
signal ControlledPawnTeleport(in_reset_camera: bool)

func _on_controlled_pawn_died(in_immediately: bool) -> void:
	
	if PlatformGlobals.is_telemetry_enabled():
		
		var death_level := WorldGlobals._level.scene_file_path.get_basename()
		var death_position := Vector2i(controlled_pawn.global_position)
		var death_source := "other"
		
		if controlled_pawn.damage_receiver:
			
			var last_damage_source := controlled_pawn.damage_receiver.LastDamageSource
			var last_damage_instigator := controlled_pawn.damage_receiver.LastDamageInstigator
			
			if last_damage_source is Pawn2D:
				death_source = String(last_damage_source.unique_name)
			elif last_damage_instigator is Pawn2D:
				death_source = String(last_damage_instigator.unique_name)
			elif not last_damage_source.scene_file_path.is_empty():
				death_source = last_damage_source.scene_file_path.get_file().get_slice(".", 0)
			elif not last_damage_instigator.scene_file_path.is_empty():
				death_source = last_damage_instigator.scene_file_path.get_file().get_slice(".", 0)
		
		PlatformGlobals.send_telemetry("player_death", { "level": death_level, "position": death_position, "source": death_source }, false)

func _on_controlled_pawn_tree_exited() -> void:
	controlled_pawn = null

func get_new_pawn_scene_path() -> String:
	return default_pawn_scene_path

func restart(in_initial_restart: bool = false) -> void:
	
	var _level := WorldGlobals._level as LevelBase2D
	var RestartPosition := _level.get_player_spawn_position(self)
	
	controlled_pawn = (load(get_new_pawn_scene_path()) as PackedScene).instantiate()
	controlled_pawn.position = RestartPosition
	controlled_pawn.controller = self
	
	_level._y_sorted.add_child.call_deferred(controlled_pawn)
	
	if not in_initial_restart:
		WorldGlobals._game_state.current_restarts_num += 1

func GetControlledPawnLinearVelocity() -> Vector2:
	
	if is_instance_valid(controlled_pawn):
		return PhysicsServer2D.body_get_state(controlled_pawn.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY)
	return Vector2.ZERO

##
## Inputs
##
var disable_movement_inputs: bool = false
var disable_tap_inputs: bool = false

var movement_input: Vector2

func ProcessMovementInputs(in_delta: float) -> void:
	
	if disable_movement_inputs or _camera.ShouldBlockMovementInputs():
		movement_input = Vector2.ZERO
	else:
		movement_input = Input.get_vector(&"Left", &"Right", &"Up", &"Down")
	
	if controlled_pawn:
		controlled_pawn.handle_controller_movement_input(movement_input)

func _unhandled_input(in_event: InputEvent) -> void:
	
	if in_event is InputEventScreenTouch:
		
		if disable_tap_inputs or _camera.ShouldBlockTapInputs():
			pass
		else:
			handle_tap_input(in_event.position, in_event.is_released())
		get_viewport().set_input_as_handled()
		
	elif in_event.is_action_pressed(&"1"):
		HandleNumberInput(1)
		get_viewport().set_input_as_handled()
		
	elif in_event.is_action_pressed(&"2"):
		HandleNumberInput(2)
		get_viewport().set_input_as_handled()
		
	elif in_event.is_action_pressed(&"3"):
		HandleNumberInput(3)
		get_viewport().set_input_as_handled()

var TapInputCallableArray: Array[Callable] = []

signal TapInputHandled(in_screen_position: Vector2, in_global_position: Vector2, in_released: bool, InConsumedByPawn: bool)

func handle_tap_input(in_screen_position: Vector2, in_released: bool) -> void:
	
	var GlobalPosition := get_viewport().get_canvas_transform().affine_inverse() * in_screen_position
	#DamageNumberUI.spawn(GlobalPosition + Vector2(randf_range(-10.0, 10.0), 0.0), 1)
	
	var ConsumedByPawn := false
	if GameGlobals.CallAllCancellable(TapInputCallableArray, [ self, GlobalPosition, in_released ]):
		pass
	elif is_instance_valid(controlled_pawn):
		controlled_pawn.handle_controller_tap_input(in_screen_position, GlobalPosition, in_released)
		ConsumedByPawn = true
	
	TapInputHandled.emit(in_screen_position, GlobalPosition, in_released, ConsumedByPawn)

func HandleJumpInput() -> void:
	if controlled_pawn:
		controlled_pawn.handle_controller_jump_input()

func HandleNumberInput(InNumber: int) -> void:
	#_Inventory.TryUseActiveArtifactByIndex(InNumber - 1)
	pass

##
## UI
##
signal fade_in_trigger(in_duration: float, in_color: Color, in_blend: float)
signal fade_out_trigger(in_duration: float, in_color: Color, in_blend: float)

func trigger_fade_in(in_duration: float, in_color: Color = Color.BLACK, in_blend: float = 0.2) -> void:
	
	if in_duration > 0.0:
		fade_in_trigger.emit(in_duration, in_color, in_blend)
		await GameGlobals.spawn_await_timer(self, in_duration).timeout

func trigger_fade_out(in_duration: float, in_color: Color = Color.BLACK, in_blend: float = 0.2) -> void:
	
	if in_duration > 0.0:
		fade_out_trigger.emit(in_duration, in_color, in_blend)
		await GameGlobals.spawn_await_timer(self, in_duration).timeout
