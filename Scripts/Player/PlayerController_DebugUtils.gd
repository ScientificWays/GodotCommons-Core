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
		pass
	elif InEvent.is_action_pressed(&"DebugScrollUp"):
		OwnerPlayerController._Camera.PendingZoom *= 1.25
		print("Set camera zoom to ", OwnerPlayerController._Camera.PendingZoom)
		pass
	elif InEvent.is_action_pressed(&"DebugScrollDown"):
		OwnerPlayerController._Camera.PendingZoom *= 0.8
		print("Set camera zoom to ", OwnerPlayerController._Camera.PendingZoom)
		pass

func DebugTeleport():
	var TeleportPosition := OwnerPlayerController.ControlledPawn.get_global_mouse_position()
	OwnerPlayerController.ControlledPawn.TeleportTo(TeleportPosition)
