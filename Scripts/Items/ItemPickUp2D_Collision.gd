extends CollisionShape2D
class_name ItemPickUp2D_Collision

@export_category("Owner")
@export var OwnerItemPickUp: ItemPickUp2D

func _ready() -> void:
	OwnerItemPickUp.body_entered.connect(OnTargetEntered)

func OnTargetEntered(InTarget: Node) -> void:
	OwnerItemPickUp.TryPickUpBy(InTarget)
