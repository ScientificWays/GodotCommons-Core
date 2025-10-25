extends Resource
class_name PawnDashVariantData2D

@export_category("Duration")
@export var duration: float = 1.0

@export_category("Launch")
@export var impulse: float = 100.0
@export var launch_delay: float = 0.0
@export var launch_velocity_damp: float = 3.0
@export var ignore_mass: bool = true

@export_category("Contact")
@export var instant_contact_damage: bool = false

@export_category("Animation")
@export var animation_name: StringName = &"Dash"
@export var should_reset_animation_on_finish: bool = true
