extends RigidBody2D
class_name ItemPickUp2D

@export_category("Info")
@export var ItemName: StringName

@export_category("Pick Up")
@export var RemoveOnPickUp: bool = true
@export var PickUpAP: AnimationPlayer
@export var PickUpAnimaionName: StringName = &"PickUp"

signal PickUp(InTarget: Node)

func CanPickUpBy(InTarget: Node) -> bool:
	return is_instance_valid(InTarget)

func TryPickUpBy(InTarget: Node) -> bool:
	
	if not CanPickUpBy(InTarget):
		return false
	
	add_collision_exception_with(InTarget)
	
	PickUp.emit(InTarget)
	
	if PickUpAP:
		PickUpAP.play(PickUpAnimaionName)
		await PickUpAP.animation_finished
	
	if RemoveOnPickUp:
		queue_free()
	return true
