extends Node
class_name PlayerController_DebugUtils

@export_category("Owner")
@export var OwnerPlayerController: PlayerController

func _ready() -> void:
	
	assert(OwnerPlayerController)
	
	if not OS.has_feature("debug"):
		queue_free()

func _unhandled_input(InEvent: InputEvent):
	
	if InEvent.is_action_pressed(&"DebugAction"):
		#DebugSpawnCreature()
		#DebugSpawnExplosion()
		DebugTeleport()
		#DebugSpawnItem()
		#DebugApplyStatusEffect()
		#DebugSelfDamage()
		#DebugUnlock()
		#DebugToggleVisibility()
		get_viewport().set_input_as_handled()
		
	elif InEvent.is_action_pressed(&"DebugScrollUp"):
		OwnerPlayerController._camera.PendingZoom *= 1.25
		print("Set camera zoom to ", OwnerPlayerController._camera.PendingZoom)
		get_viewport().set_input_as_handled()
		
	elif InEvent.is_action_pressed(&"DebugScrollDown"):
		OwnerPlayerController._camera.PendingZoom *= 0.8
		print("Set camera zoom to ", OwnerPlayerController._camera.PendingZoom)
		get_viewport().set_input_as_handled()
		

func DebugTeleport():
	
	if not is_instance_valid(OwnerPlayerController.ControlledPawn):
		return
	
	var TeleportPosition := OwnerPlayerController.ControlledPawn.get_global_mouse_position()
	OwnerPlayerController.ControlledPawn.teleport_to(TeleportPosition)
