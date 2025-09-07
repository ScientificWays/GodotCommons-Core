extends Sprite2D
class_name Gib2D_Collision

@export_category("Owner")
@export var OwnerGib: Gib2D

func _ready() -> void:
	
	if OwnerGib.ShouldFreezeOnSleep:
		OwnerGib.sleeping_state_changed.connect(OnOwnerSleepingStateChanged)

func OnOwnerSleepingStateChanged():
	assert(OwnerGib.ShouldFreezeOnSleep)
	set_deferred("disabled", OwnerGib.sleeping)
