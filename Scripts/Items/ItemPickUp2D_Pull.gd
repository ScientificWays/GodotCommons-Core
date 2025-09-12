extends Area2D
class_name ItemPickUp2D_Pull

@export_category("Owner")
@export var OwnerItemPickUp: ItemPickUp2D

@export_category("Force")
@export var PullForce: float = 32.0

func _ready() -> void:
	OwnerItemPickUp.body_entered.connect(OnTargetEntered)

func OnTargetEntered(InTarget: Node) -> void:
	OwnerItemPickUp.sleeping = false

func _physics_process(InDelta: float) -> void:
	
	var PullTargets := get_overlapping_areas() + get_overlapping_bodies()
	for SampleTarget: Node2D in PullTargets:
		
		if OwnerItemPickUp.CanPickUpBy(SampleTarget):
			var ForceDirection := global_position.direction_to(SampleTarget.global_position)
			OwnerItemPickUp.apply_central_force(ForceDirection * PullForce)
