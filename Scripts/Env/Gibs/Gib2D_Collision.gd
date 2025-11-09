extends CollisionShape2D
class_name Gib2D_Collision

@export_category("Owner")
@export var OwnerGib: Gib2D

func _ready() -> void:
	
	if OwnerGib.should_freeze_on_sleep:
		OwnerGib.sleeping_state_changed.connect(OnOwnerSleepingStateChanged)

func OnOwnerSleepingStateChanged():
	assert(OwnerGib.should_freeze_on_sleep)
	set_deferred("disabled", OwnerGib.sleeping)
